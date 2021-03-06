#!/bin/bash

########### 此脚本会被vagrant调用， 修改慎重

. /data/opt/env.sh

cleanup=$1
hn=$2

if [[ x$cleanup == x ]]
then
    cleanup=0
fi

user=lidong
ssh_dir="/home/$user/.ssh/"
ssh_cnf="config"
ssh_key="id_rsa"

WS_DIR=/home/$user/workspace
CONF_DIR=/home/$user/nfs

HADOOP_HOME=/opt/hadoop
ZOOKEEPER_HOME=/opt/zookeeper
HBASE_HOME=/opt/hbase
AVRO_HOME=/opt/avro

HADOOP_DIFF=$CONF_DIR/hadoop
ZOOKEEPER_DIFF=$CONF_DIR/nfs/zookeeper
HBASE_DIFF=$CONF_DIR/nfs/hbase
AVRO_VER=1.8.2

if [[ x$hn == x ]]
then
    hn=node0
    CONF_DIR=`pwd`
    HADOOP_DIFF=$CONF_DIR/$hn/hadoop
    ZOOKEEPER_DIFF=$CONF_DIR/$hn/zookeeper
fi

COMMON_DIR=$CONF_DIR/common

###### 系统设置 ######
__system_conf() {
    echo "-----> $FUNCNAME"

    if [[ ! -f /home/$user/.ssh.tar.gz ]]
    then
        cd /home/$user/
        tar zcf .ssh.tar.gz .ssh
        cd -
    fi

    if (( $cleanup == 1 ))
    then
        rm -f $ssh_dir/$ssh_key
        rm -f $ssh_dir/$ssh_cnf
        rm -f /opt/ws
    fi

    if [ ! -f $ssh_dir/$ssh_key -a $USER == "root" ]
    then
        ssh-keygen -t rsa -f $ssh_dir/$ssh_key -P ""
    else 
        cp $COMMON_DIR/linux/ssh/* /home/$user/.ssh
    fi

    if [[ ! -f $ssh_dir/$ssh_cnf ]]
    then
        # 登录时是否询问 (no)
        echo "StrictHostKeyChecking no" >  $ssh_dir/$ssh_cnf
        # 表示隐藏known_hosts文件
        echo "UserKnownHostsFile /dev/null" >> $ssh_dir/$ssh_cnf
        # 减少SSH带来的提示
        echo "LogLevel FATAL" >> $ssh_dir/$ssh_cnf
    fi
    chown $user:$user $ssh_dir -R

    if [[ ! -d $WS_DIR ]]
    then
        mkdir -p $WS_DIR
        sudo chown $user:$user $WS_DIR
    fi

    if [[ ! -L /opt/ws ]]
    then
        # 一些配置文件中使用/opt/ws/路径, 如core-site.xml
        sudo ln -s $WS_DIR /opt/ws
    fi

    # 关闭防火强
    sudo ufw disable

    # 更改/etc/配置 (物理机需要自己添加hosts)
    if [[ -d $COMMON_DIR/linux/etc/ ]]
    then
        if [ $USER == "root" ]
        then
            if [ -f $COMMON_DIR/linux/etc/localtime ];
            then
                rm /etc/localtime
            fi
            if [ -f $COMMON_DIR/linux/etc/timezone ];
            then
                rm /etc/timezone
            fi
            cp -arf $COMMON_DIR/linux/etc/* /etc
            # 替换127.0.0.1 为本机的ip
            # ip=`grep $hn /etc/hosts | cut -d\  -f1`
            # sed -i "s/127.0.0.1/$ip/g" /etc/hosts
            chown root:root /etc/sudoers
        else
            files=`ls $COMMON_DIR/linux/etc/`
            echo "WANRNING! files underside NEED MELD TO YOUR HOST MENUALY"
            echo $files
            echo "WANRNING! files above NEED MELD TO YOUR HOST MENUALY"
        fi
    fi

    # 显示时间
    date
}

###### Zookeeper配置 ######
__zookeeper_conf() {
    echo "-----> $FUNCNAME"

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

    cd - 1 &>/dev/null
}

###### Hadoop配置 ######
__hadoop_conf() {
    echo "-----> $FUNCNAME"

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

        # 将Hadoop中的core-site.xml hdfs-site.xml同步到hbase中 或者配置 HBASE_CLASSPATH
        cp -arpf $COMMON_DIR/hadoop/etc/core-site.xml $HBASE_HOME/conf
        cp -arpf $COMMON_DIR/hadoop/etc/hdfs-site.xml $HBASE_HOME/conf
    fi
    chown -R $user:$user $WS_DIR/hadoop

    # 在copy差异配置
    if [[ -d $HADOOP_DIFF/etc ]]
    then
        cp -arpf $HADOOP_DIFF/etc/* etc/hadoop
        cp -arpf $HADOOP_DIFF/etc/* $HBASE_HOME/conf
    fi
    chown -R $user:$user etc

    # 统一zookeeper
    cp $ZOOKEEPER_HOME/zookeeper-3.4.10.jar  share/hadoop/common/lib/

    cd - 1 &>/dev/null
}

__hbase_conf() {
    echo "-----> $FUNCNAME"

    cd $HBASE_HOME

    if [[ ! -f conf.tar.gz ]]
    then
        tar zcf conf.tar.gz conf
    fi
    rm -rf conf
    tar zxf conf.tar.gz 

    if [[ ! -d $WS_DIR/hbase ]]
    then
        mkdir -p $WS_DIR/hbase/tmp
        mkdir -p $WS_DIR/hbase/logs
    fi

    # 先copy公共配置
    if [[ -d $COMMON_DIR/hbase/conf ]]
    then
        cp -arpf $COMMON_DIR/hbase/conf/* conf

        # 将Hbase的配置同时 copy 到 hadoop 中
        cp -arpf $COMMON_DIR/hbase/conf/* $HADOOP_HOME/etc/hadoop/
    fi
    chown -R $user:$user $WS_DIR/hbase

    # 在copy差异配置
    if [[ -d $HBASE_DIFF/conf ]]
    then
        cp -arpf $HBASE_DIFF/conf/* conf
        # 将差异文件同步到hadoop配置
        cp -arpf $HBASE_DIFF/conf/* $HADOOP_HOME/etc/hadoop/
    fi
    chown -R $user:$user conf

    # log4统一, 删除掉, 统一使用hadoop中的 (# export HBASE_DISABLE_HADOOP_CLASSPATH_LOOKUP=)
    if [ -e lib/log4j*.jar ];
    then
        echo "gzip lib/log4j*.jar lib/slf4j*.jar"
        gzip lib/log4j*.jar lib/slf4j*.jar
    fi
    cd - 1 &>/dev/null
}

__avro_conf() {
    echo "-----> $FUNCNAME"
    cd $HADOOP_HOME/share/hadoop/common/lib
    if [[ -f avro-1.7.4.jar ]]
    then
        gzip avro-1.7.4.jar
    else
        cp $AVRO_HOME/avro-${AVRO_VER}.jar .
        cp $AVRO_HOME/avro-mapred-${AVRO_VER}-hadoop2.jar .
        cp $AVRO_HOME/avro-tools-${AVRO_VER}.jar ../../tools/lib
    fi
    cd - 1 &>/dev/null
}

__main() {
    echo "-----> $FUNCNAME"

    if (( $cleanup == 1 ))
    then
        echo "cleanup: *** "
        if [[ -d $WS_DIR ]]
        then
            rm -rf $WS_DIR/*
        fi
    fi

    __system_conf
    __zookeeper_conf
    __hadoop_conf
    __hbase_conf
    __avro_conf
}

__main
