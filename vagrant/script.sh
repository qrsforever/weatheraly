#!/bin/bash

########### 此脚本会被vagrant调用， 修改慎重

cleanup=$1
hn=$2

if [[ x$hn == x ]]
then
    echo "user: script.sh hostname"
    echo "Not run by vagrant, host mode"
fi

if [[ x$cleanup == x ]]
then
    cleanup=0
fi

user=lidong
rsa_file=/home/$user/.ssh/id_rsa
ssh_conf=/home/$user/.ssh/config
whoami=/home/$user/whoami.txt

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

__main() {

    if (( $cleanup == 1 ))
    then
        echo "cleanup: *** "
        if [[ -d $WS_DIR ]]
        then
        rm -rf $WS_DIR
        fi

        if [[ -f $whoami ]]
        then
            rm -rf $whoami
        fi
    fi

    if [[ x$hn != x ]]
    then
        __system_conf $hn
    fi

    __hadoop_conf $hn

    echo "# 注意启动顺序 " >> $whoami
    echo "# zookeeper > journalnode > format > namenode > datanode " >> $whoami


    echo "###" > $whoami
    for t in ${tasks[@]}
    do
        if [[ x$t == x'NN' ]]
        then
            echo "hdfs namenode -format" >> $whoami
        fi

        if [[ x$t == x'ZK' ]]
        then
            __zookeeper_conf $hn
            echo "Zookeeper node" >> $whoami
        fi

        if [[ x$t == x'JN' ]]
        then
            echo "Journal node" >> $whoami
        fi

        if [[ x$t == x'NN' ]]
        then
            echo "Name node" >> $whoami
        fi

        if [[ x$t == x'FC' ]]
        then
            echo "FailoverController node" >> $whoami
        fi

        if [[ x$t == x'RM' ]]
        then
            echo "Resource manger node" >> $whoami
        fi

        if [[ x$t == x'DN' ]]
        then
            echo "Data node" >> $whoami
        fi
    done
}

__main
