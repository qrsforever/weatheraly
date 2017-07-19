#!/bin/bash

bin=`dirname ${BASH_SOURCE-$0}`

$bin/stop-vm.sh $1
$bin/start-vm.sh $1
