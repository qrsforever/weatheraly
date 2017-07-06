采用HDFS High Availability Using the Quorum Journal Manager 方案来实现HA.

Cluster布局

        NN  RM  NM  DN  JN  ZK  FC
node0:  v   v                   v 
node1:  v                       v
node2:          v   v   v   v
node3:          v   v   v   v
node4:          v   v   v   v
node5:      v

基本环境配置

Vagrant box (集成了Hadoop软件):

    1. 下载: https://pan.baidu.com/s/1eS6BDbO hadoop-vm.box

    2. 添加到vagrant环境中: vagrant box add hadoop-vm hadoop-vm.box

    (其他使用参考: https://github.com/qrsforever/workspace/tree/master/java/learn/hadoop/vagrant)

　
    使用vagrant可以在一台物理机上虚拟出多个vm机，通过之前做好的ubuntu镜像(已集成hadoop，zookeeper, 以及环境的配置等), vagrant up 出若干个vm。

vagrant的好处在于，它可以通过VagrantFile文件自动地修改vm机的一些配置,如 ip，mac, hostname, 还可以执行脚本(vagrant/script.sh).

    另外一些环境变量的配置放到了ubuntu系统的/data/opt/env.sh(https://github.com/qrsforever/opt)中, 该脚本在~/.profile被执行.

VagrantFile: 负责启动虚拟机， 配置每台虚拟机的ip, mac, hostname, 创建必要的目录， nfs映射, vm启动后执行脚本等。

script.sh: 物理机和虚拟机都会执行，负责配置集群里的细节环境, 被start-vm.sh和vagrant调用。
    
启动虚拟机和集群:

  bin/start-vm.sh 1 or bin/start-vm.sh

  bin/start-cluster.sh


start-vm.sh: 启动虚拟机

start-cluster.sh: 启动集群中必要的服务

stop-cluster.sh: 停止集群中的服务

chk-status.py: 查看集群中的状态，如jps.

