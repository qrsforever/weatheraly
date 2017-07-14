#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import os
from common_utils import print_with_color

def _chk_jps_status(id):
    """
    查看集群中每个节点的jps进程
    """
    node = "node" + id
    print_with_color("check jps: " + node)
    os.system("ssh -o LogLevel=ERROR " + node + " jps | grep -vi jps")

def _chk_zk_status():
    for i in ('2', '3', '4'):
        node = "node" + i
        print_with_color("-------> " + node)
        os.system("ssh -o LogLevel=ERROR " + node + " \". /data/opt/env.sh; zkServer.sh status\"");

def _chk_ulimit_status(id):
    """
    查看集群中每个节点的limit -a
    """
    node = "node" + id
    print_with_color("check limit: " + node)
    os.system("ssh -o LogLevel=ERROR " + node + " ulimit -a")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Use: ", sys.argv[0], " [jps|zk|ulimit]")
        sys.exit(0)

    arg = sys.argv[1] 

    if arg == "zk":
        _chk_zk_status()
        sys.exit(0)

    for i in range(6):
        if arg == "jps":
            _chk_jps_status(str(i))
        elif arg == "ulimit":
            _chk_ulimit_status(str(i))
