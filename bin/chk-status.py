#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import os
from common_utils import print_with_color

def _chk_jps_status():
    """
    查看集群中每个节点的jps进程
    """
    for i in range(6):
        node = "node" + str(i) 
        print_with_color("check jps: " + node)
        os.system("ssh -o LogLevel=ERROR " + node + " jps | grep -vi jps")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("User: ", sys.argv[0], " [jps]")
        sys.exit(0)

    arg = sys.argv[1] 
    if arg == "jps":
        _chk_jps_status()
