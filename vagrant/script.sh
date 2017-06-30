#!/bin/bash

########### 此脚本会被vagrant调用， 修改慎重

hn=$1

if [[ x$hn == x ]]
then
    echo "user: script.sh hostname"
    echo "Not run by vagrant, host mode"
fi

user=lidong
rsa_file=/home/$user/.ssh/id_rsa
ssh_conf=/home/$user/.ssh/config
script_file=/home/$user/run.sh
echo -e "#!/bin/bash\n" > $script_file

WS_DIR=/home/$user/workspace
CONF_DIR=/home/$user/nfs

HADOOP_HOME=/opt/hadoop
ZOOKEEPER_HOME=/opt/zookeeper

HADOOP_DIFF=$CONF_DIR/hadoop
ZOOKEEPER_DIFF=/home/$user/nfs/zookeeper

if [[ x$hn == x ]]
then
    CONF_DIR=`pwd`
    HADOOP_DIFF=$CONF_DIR/node0/hadoop
    ZOOKEEPER_DIFF=$CONF_DIR/node0/zookeeper
fi

COMMON_DIR=$CONF_DIR/common

###### 系统设置 ######
__system_conf() 
{
    if [[ ! -f $rsa_file ]]
    then
        ssh-keygen -t rsa -f $rsa_file -P ""
        chown $user:$user $rsa_file
    fi

    if [[ ! -f $ssh_conf ]]
    then
        echo "StrictHostKeyChecking no" >  $ssh_conf
        echo "UserKnownHostsFile /dev/null" >> $ssh_conf
        chown $user:$user $ssh_conf
    fi

    if [[ ! -d $WS_DIR ]]
    then
        mkdir -p $WS_DIR
        chown $user:$user $WS_DIR
    fi
    chown $user:$user $script_file

    if [[ ! -L /opt/ws ]]
    then
        ln -s $WS_DIR /opt/ws
    fi

    # 关闭防火强
    ufw disable

    # 更改/etc/配置
    if [[ -d $COMMON_DIR/linux/etc/ ]]
    then
        cp $COMMON_DIR/linux/etc/* /etc
    fi

    tasks=(`cat $COMMON_DIR/hosts-duty.txt | grep $hn | cut -d\: -f2`)
}

###### Hadoop配置 ######
__hadoop_conf() {
    # 软连接: /opt/hadoop --> /data/opt/hadoop/hadoop-2.8.0
    cd $HADOOP_HOME

    if [[ ! -f etc.tar.gz ]]
    then
        tar zcf etc.tar.gz etc
    fi
    rm -rf logs
    rm -rf etc
    tar zxf etc.tar.gz 

    if [[ ! -d $WS_DIR/hadoop ]]
    then
        mkdir -p $WS_DIR/hadoop/tmp
        mkdir -p $WS_DIR/hadoop/logs
    fi

    # 先copy公共配置
    if [[ -d $COMMON_DIR/hadoop/etc ]]
    then
        cp -arpf $COMMON_DIR/hadoop/etc/* etc/hadoop
    fi
    chown -R $user:$user $WS_DIR/hadoop

    # 在copy差异配置
    if [[ -d $HADOOP_DIFF/etc ]]
    then
        cp -arpf $HADOOP_DIFF/etc/* etc/hadoop
    fi
    chown -R $user:$user etc

    cd -
}

###### Zookeeper配置 ######
__zookeeper_conf() {
    # 软连接: /opt/zookeeper --> /data/opt/zookeeper/zookeeper-3.4.10
    cd $ZOOKEEPER_HOME

    if [[ ! -f conf.tar.gz ]]
    then
        tar zcf conf.tar.gz conf
    fi
    rm -rf conf
    tar zxf conf.tar.gz 

    if [[ ! -d $WS_DIR/zookeeper ]]
    then
        mkdir -p $WS_DIR/zookeeper/data
        mkdir -p $WS_DIR/zookeeper/logs
    fi

    rm -f $WS_DIR/zookeeper/data/myid
    if [[ -f $CONF_DIR/zookeeper/data/myid ]]
    then
        cp $CONF_DIR/zookeeper/data/myid $WS_DIR/zookeeper/data/myid
    fi
    chown -R $user:$user $WS_DIR/zookeeper

    # 先copy公共配置
    if [[ -d $COMMON_DIR/zookeeper/conf ]]
    then
        cp -aprf $COMMON_DIR/zookeeper/conf/* conf
    fi

    # 在copy差异配置
    if [[ -d $ZOOKEEPER_DIFF/conf ]]
    then
        cp -aprf $ZOOKEEPER_DIFF/conf/* conf
    fi
    chown -R $user:$user conf

    cd -
}

if [[ x$hn != x ]]
then
    __system_conf $hn
fi

__hadoop_conf $hn

echo "# 注意启动顺序 " >> $script_file
echo "# zookeeper > journalnode > format > namenode > datanode " >> $script_file

for t in ${tasks[@]}
do
    if [[ x$t == x'NN' ]]
    then
        echo "hdfs namenode -format" >> $script_file
    fi

    if [[ x$t == x'ZK' ]]
    then
        __zookeeper_conf $hn
        echo "# 启动zookeeper" >> $script_file
        echo "zkServer.sh start" >> $script_file
        echo "sleep 5" >> $script_file
        echo "zkServer.sh status" >> $script_file
    fi

    if [[ x$t == x'JN' ]]
    then
        echo "# 先于hdfs namenode -format执行" >> $script_file
        echo "# 启动namenode日志同步服务journalnode" >> $script_file
        echo "hadoop-daemon.sh start journalnode" >> $script_file
    fi

    if [[ x$t == x'NN' ]]
    then
        echo "# 在主namenode格式化hdfs namenode -format之后" >> $script_file
        echo "# 同步并启用备用namenode" >> $script_file
        echo "hdfs namenode -bootstrapStandby" >> $script_file
        echo "hadoop-daemon.sh start namenode" >> $script_file
        echo "# 在其中一台namenode执行即可" >> $script_file
        echo "hdfs zkfc -formatZK" >> $script_file
        echo "# 在一台namendoe上启动即可" >> $script_file
        echo "start-dfs.sh" >> $script_file
    fi

    if [[ x$t == x'FC' ]]
    then
        echo "# 启动DFSZKFailoverController(需要启动的节点都启动)" >> $script_file
        echo "hadoop-daemon.sh start zkfc" >> $script_file
    fi

    if [[ x$t == x'RM' ]]
    then
        echo "# 启动RM" >> $script_file
        echo "start-yarn.sh" >> $script_file
        echo "# yarn-daemon.sh start resourcemanager" >> $script_file
    fi

done

chmod 777 $script_file
