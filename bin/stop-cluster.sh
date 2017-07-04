#!/bin/bash

bin=`dirname ${BASH_SOURCE-$0}`
topdir=`cd $bin/../; pwd`
run_env=". /data/opt/env.sh"

. $bin/shell_utils.sh

# 1. 停止zookeeper
__stop_zookeeper() {
    echo "-----> $FUNCNAME"

    print_with_color "关闭ZooKeeper集群"
    ssh node2 "$run_env; zkServer.sh stop"
    ssh node3 "$run_env; zkServer.sh stop"
    ssh node4 "$run_env; zkServer.sh stop"
}

# 2. 停止namenode日志同步服务(在格式化namenode之前)
__stop_journalnode() {
    echo "-----> $FUNCNAME"

    print_with_color "关闭JournalNode集群"
    ssh node2 "$run_env; hadoop-daemon.sh stop journalnode"
    ssh node3 "$run_env; hadoop-daemon.sh stop journalnode"
    ssh node4 "$run_env; hadoop-daemon.sh stop journalnode"
}

# 3. 停止分布式系统 
__stop_hadoop() {
    echo "-----> $FUNCNAME"

    print_with_color "关闭历史日志服务"
    ssh node0 "$run_env; mr-jobhistory-daemon.sh stop historyserver"
    ssh node1 "$run_env; mr-jobhistory-daemon.sh stop historyserver"

    print_with_color "关闭ZKFC"
    ssh node0 "$run_env; hadoop-daemon.sh stop zkfc"
    ssh node1 "$run_env; hadoop-daemon.sh stop zkfc"

    print_with_color "关闭YARN"
    ssh node5 "$run_env; yarn-daemon.sh stop resourcemanager"
    ssh node0 "$run_env; stop-yarn.sh"

    print_with_color "关闭集群中所有的DataNode"
    ssh node0 "$run_env; hadoop-daemons.sh stop datanode"

    print_with_color "关闭NameNode"
    ssh node0 "$run_env; hadoop-daemon.sh stop namenode"
    ssh node1 "$run_env; hadoop-daemon.sh stop namenode"
}

__main() {
    echo "-----> $FUNCNAME"
    __stop_hadoop
    __stop_journalnode
    __stop_zookeeper
}

__main
