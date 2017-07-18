#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import os
from common_utils import print_with_color

def _chk_jps_status(node):
    """
    查看集群中每个节点的jps进程
    """
    print_with_color("check jps: " + node)
    os.system("ssh -o LogLevel=ERROR " + node + " jps | grep -vi jps")

def _chk_zk_status():
    for i in ('2', '3', '4'):
        node = "node" + i
        print_with_color("-------> " + node)
        os.system("ssh -o LogLevel=ERROR " + node + " \". /data/opt/env.sh; zkServer.sh status\"");

def _chk_df_status(node):
    if node == 'node0':
        return
    print_with_color("check df: " + node)
    os.system("ssh -o LogLevel=ERROR " + node + " df -h | grep sda1")

def _chk_ulimit_status(node):
    """
    查看集群中每个节点的limit -a
    """
    print_with_color("check limit: " + node)
    os.system("ssh -o LogLevel=ERROR " + node + " ulimit -a")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Use: ", sys.argv[0], " [jps|zk|df|ulimit]")
        sys.exit(0)

    arg = sys.argv[1] 

    if arg == "zk":
        _chk_zk_status()
        sys.exit(0)

    for i in range(6):
        node = "node" + str(i)
        if arg == "jps":
            _chk_jps_status(node)
        elif arg == "ulimit":
            _chk_ulimit_status(node)
        elif arg == "df":
            _chk_df_status(node)
