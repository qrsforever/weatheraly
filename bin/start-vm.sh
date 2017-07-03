#!/bin/bash

bin=`dirname ${BASH_SOURCE-$0}`
topdir=`cd $bin/../; pwd`

vagrant_dir=$topdir/vagrant

cd $vagrant_dir

# 带有参数1， 清楚所有集群建立的数据， 重新开始
if [[ x$1 == x1 ]]
then
    export CLEANUP=1; vagrant reload --provision
else
    export CLEANUP=0; vagrant up --provision
fi

unset CLEANUP

cd -
