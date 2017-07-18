#!/bin/bash

bin=`dirname ${BASH_SOURCE-$0}`
topdir=`cd $bin/../; pwd`

vag_dir=/home/lidong/vagrant
for dir in `ls $vag_dir`
do
    sudo umount $vag_dir/$dir 2 &> /dev/null
done

$topdir/bin/stop-cluster.sh

cd $topdir/vagrant; vagrant halt; cd - 1 &>/dev/null
