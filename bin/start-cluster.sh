#!/bin/bash

bin=`dirname ${BASH_SOURCE-$0}`
topdir=`cd $bin/../; pwd`
run_env=". /data/opt/env.sh"

. $bin/shell_utils.sh

# ZooKeeper -> JournalNode (hadoop) -> NameNode (Hadoop) -> DataNode (Hadoop) -> 主 ResourceManager/NodeManager (Hadoop) -> 备份 ResourceManager (Hadoop) -> ZKFC (Hadoop) -> MapReduce JobHistory (Hadoop) -> 主 Hmaster/HRegionServer (hbase) ->备份 Hmaster 

# 1. 启动zookeeper
__start_zookeeper() {
    echo "-----> $FUNCNAME"

    print_with_color "启动zkServer(所有安装zookeeper机群上)"
    ssh node2 "$run_env; zkServer.sh start"
    ssh node3 "$run_env; zkServer.sh start"
    ssh node4 "$run_env; zkServer.sh start"

    sleep 6

    print_with_color "查看zkServer启动状态"
    ssh node2 "$run_env; zkServer.sh status" 
    ssh node3 "$run_env; zkServer.sh status" 
    ssh node4 "$run_env; zkServer.sh status" 

    print_with_color "(首次需要)格式化zookeeper集群(任意一台namenode)"
    ssh node0 "$run_env; hdfs zkfc -formatZK -nonInteractive"
    ssh node0 "$run_env; zkCli.sh -server node2 ls /" 
}

# 2. 启动namenode日志同步服务(在格式化namenode之前)
__start_journalnode() {
    echo "-----> $FUNCNAME"

    print_with_color "启动JournalNode集群(所有journalnode集群上)"
    ssh node2 "$run_env; hadoop-daemon.sh start journalnode"
    ssh node3 "$run_env; hadoop-daemon.sh start journalnode"
    ssh node4 "$run_env; hadoop-daemon.sh start journalnode"
}

# 3. 启动分布式系统 
__start_hadoop() {
    echo "-----> $FUNCNAME"

    print_with_color "(首次需要)格式化并启动NameNode集群(在其中一台namenode机器上)"
    ssh node0 "$run_env; hdfs namenode -format -nonInteractive"
    ssh node0 "$run_env; hadoop-daemon.sh start namenode"

    print_with_color "同步NameNode元数据到另一台机器上, 并启动"
    ssh node1 "$run_env; hdfs namenode -bootstrapStandby -nonInteractive"
    ssh node1 "$run_env; hadoop-daemon.sh start namenode"

    print_with_color "启动集群上所有的DataNode节点(在任意台namenode上执行)"
    ssh node0 "$run_env; hadoop-daemons.sh start datanode"

    print_with_color "启动YARN(RM + NM), 并在另一台上单独启动RM"
    ssh node0 "$run_env; start-yarn.sh"
    ssh node5 "$run_env; yarn-daemon.sh start resourcemanager"

    print_with_color "启动ZKFC(在所有的namenode集群上)"
    ssh node0 "$run_env; hadoop-daemon.sh start zkfc"
    ssh node1 "$run_env; hadoop-daemon.sh start zkfc"

    print_with_color "开启MR历史日志服务"
    ssh node0 "$run_env; mr-jobhistory-daemon.sh start historyserver"
    ssh node1 "$run_env; mr-jobhistory-daemon.sh start historyserver"
}

__main() {
    echo "-----> $FUNCNAME"
    __start_zookeeper
    __start_journalnode
    __start_hadoop
}

__main
