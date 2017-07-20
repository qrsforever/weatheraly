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

def _chk_netstat_status(node):
    if node == 'node0':
        print_with_color("check netstat: node0")
        os.system("netstat -tuplan")
        return
    print_with_color("check netstat: " + node)
    os.system("ssh -o LogLevel=ERROR " + node + " netstat -tuplan")

def _chk_date_status(node):
    if node == 'node0':
        print_with_color("check date: node0")
        os.system("date +\"%Y-%m-%d %H:%M:%S\"")
        return
    print_with_color("check date: " + node)
    os.system('ssh -o LogLevel=ERROR ' + node + ' date +\"%Y-%m-%d\ %H:%M:%S\"')

def _chk_ulimit_status(node):
    """
    查看集群中每个节点的limit -a
    """
    print_with_color("check limit: " + node)
    os.system("ssh -o LogLevel=ERROR " + node + " ulimit -a")

def __chk_rm_status():
    print_with_color("check rm: node0")
    os.system("yarn rmadmin -getServiceState rm1");
    print_with_color("check rm: node5")
    os.system("yarn rmadmin -getServiceState rm2");

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Use: ", sys.argv[0], " [jps|zk|df|netstat|date|ulimit|rm]")
        sys.exit(0)

    arg = sys.argv[1] 

    if arg == "zk":
        _chk_zk_status()
        sys.exit(0)

    if arg == "rm":
        __chk_rm_status()
        sys.exit(0)

    for i in range(6):
        node = "node" + str(i)
        if arg == "jps":
            _chk_jps_status(node)
        elif arg == "df":
            _chk_df_status(node)
        elif arg == "netstat":
            _chk_netstat_status(node)
        elif arg == "date":
            _chk_date_status(node)
        elif arg == "ulimit":
            _chk_ulimit_status(node)


#  yarn rmadmin -getServiceState rm1
