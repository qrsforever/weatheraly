#!/bin/bash

bin=`dirname ${BASH_SOURCE-$0}`
topdir=`cd $bin/../; pwd`

run_env=". /data/opt/env.sh"

# 启动顺序: zookeeper journalnode namenode datanode resourcemanager

# 1. 启动zookeeper
__start_zookeeper() {
    echo "-----> $FUNCNAME"
    ssh node2 "$run_env; zkServer.sh start"
    ssh node3 "$run_env; zkServer.sh start"
    ssh node4 "$run_env; zkServer.sh start"
    sleep 6
    ssh node2 "$run_env; zkServer.sh status" 
    ssh node3 "$run_env; zkServer.sh status" 
    ssh node4 "$run_env; zkServer.sh status" 

    # 查看根目录
    ssh node2 "$run_env; hdfs zkfc -formatZK"
    ssh node0 "$run_env; zkCli.sh -server node2 ls /" 
}

# 2. 启动namenode日志同步服务
__start_journalnode() {
    echo "-----> $FUNCNAME"
    ssh node2 "$run_env; hadoop-daemon.sh start journalnode"
    ssh node3 "$run_env; hadoop-daemon.sh start journalnode"
    ssh node4 "$run_env; hadoop-daemon.sh start journalnode"
    # 另一中前台启动: hdfs journalnode
}

# 3. 启动分布式系统 
__start_hadoop() {
    echo "-----> $FUNCNAME"
    ssh node0 "$run_env; hdfs namenode -format"
    ssh node0 "$run_env; hadoop-daemon.sh start namenode"

    ssh node1 "$run_env; hdfs namenode -bootstrapStandby"
    ssh node1 "$run_env; hadoop-daemon.sh start namenode"

    ssh node0 "$run_env; hadoop-daemon.sh start zkfc"
    ssh node1 "$run_env; hadoop-daemon.sh start zkfc"

    ssh node0 "$run_env; hadoop-daemons.sh start datanode"

    # RM + NM
    ssh node0 "$run_env; start-yarn.sh"
    # 备用RM
    ssh node5 "$run_env; yarn-daemon.sh start resourcemanager"
}

__main() {
    echo "-----> $FUNCNAME"
    __start_zookeeper
    __start_journalnode
    __start_hadoop
}

__main
