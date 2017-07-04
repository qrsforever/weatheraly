#!/bin/bash

bin=`dirname ${BASH_SOURCE-$0}`
topdir=`cd $bin/../; pwd`

vagrant_dir=$topdir/vagrant

__ssh_conf() 
{
    # node0 是host主机， not虚拟机
    # vagrant up node1 node2 node3 node4 node5 之后

    ssh node0 cat /home/$1/.ssh/id_rsa.pub >  /tmp/authorized_keys 
    ssh node1 cat /home/$1/.ssh/id_rsa.pub >> /tmp/authorized_keys 
    ssh node2 cat /home/$1/.ssh/id_rsa.pub >> /tmp/authorized_keys 
    ssh node3 cat /home/$1/.ssh/id_rsa.pub >> /tmp/authorized_keys 
    ssh node4 cat /home/$1/.ssh/id_rsa.pub >> /tmp/authorized_keys 
    ssh node5 cat /home/$1/.ssh/id_rsa.pub >> /tmp/authorized_keys 

    scp -r /tmp/authorized_keys node0:/home/$1/.ssh
    scp -r /tmp/authorized_keys node1:/home/$1/.ssh
    scp -r /tmp/authorized_keys node2:/home/$1/.ssh
    scp -r /tmp/authorized_keys node3:/home/$1/.ssh
    scp -r /tmp/authorized_keys node4:/home/$1/.ssh
    scp -r /tmp/authorized_keys node5:/home/$1/.ssh
}

cd $vagrant_dir

# 带有参数1， 清楚所有集群建立的数据，重新开始(或者第一次启动)
if [[ x$1 == x1 ]]
then
    # 执行本机的脚本
    ../vagrant/script.sh 1
    # 启动虚拟机
    export CLEANUP=1; vagrant reload --provision
    # 配置集群彼此免密登录
    __ssh_conf $USER
else
    export CLEANUP=0; vagrant up --provision
fi

unset CLEANUP

cd -
