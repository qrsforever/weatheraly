#!/bin/bash

bin=`dirname ${BASH_SOURCE-$0}`
topdir=`cd $bin/../; pwd`

vagrant_dir=$topdir/vagrant
ssh_dir="/home/$USER/.ssh"
ssh_key="id_rsa"

vm_num=5

__ssh_conf() 
{
    # node0 是host主机， not虚拟机
    # vagrant up node1 node2 node3 node4 node5 之后
    cat $ssh_dir/${ssh_key}.pub  >  /tmp/authorized_keys 

    for i in `seq $vm_num`
    do
        ssh node$i cat $ssh_dir/${ssh_key}.pub  >>  /tmp/authorized_keys 
    done

    for i in `seq $vm_num`
    do
        scp -r /tmp/authorized_keys node$i:$ssh_dir
    done

    cp /tmp/authorized_keys  $ssh_dir
}

cd $vagrant_dir

# 带有参数1， 清楚所有集群建立的数据，重新开始(或者第一次启动)
if [[ x$1 == x1 ]]
then
    export CLEANUP=1;
    vagrant halt;
    ../vagrant/script.sh 1
else
    export CLEANUP=0;
fi

# 启动虚拟机, 不要直接执行vagrant up --provision, 否则script.sh被执行多次, Vagrant 自身Bug
for i in `seq $vm_num`
do
    echo ">>>>>>>>>>>>>>>>>>>>>>>>>>> $i"
    vagrant up node$i --provision
done

if [[ x$1 == x1 ]]
then
    # 配置集群彼此免密登录
    __ssh_conf
fi

unset CLEANUP

cd - 1 &>/dev/null
