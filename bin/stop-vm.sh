#!/bin/bash

bin=`dirname ${BASH_SOURCE-$0}`
topdir=`cd $bin/../; pwd`

$topdir/bin/stop-cluster.sh
cd $topdir/vagrant; vagrant suspend; cd - 1 &>/dev/null