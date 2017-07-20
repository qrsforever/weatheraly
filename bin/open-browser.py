#!/usr/bin/python3
# -*- coding: utf-8 -*-

import webbrowser
import sys
import os
from common_utils import print_with_color

def open_web(url):
    handle = webbrowser.get()
    handle.open(url)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Use: ", sys.argv[0], " [hadoop|yarn|hbase|ha-doc|hb-doc]")
        sys.exit(0)

    arg = sys.argv[1]
    if arg == 'hadoop':
        # 打开Hadoop管理界面
        # 50070端口, nn1, nn2见hdfs-site.xml
        res = os.popen("hdfs haadmin -getServiceState nn1 | grep active").read()
        for line in res.split('\n'):
            if line == 'active':
                print_with_color("Open Hadoop Admin Web(node0)")
                open_web("http://node0:50070")
                sys.exit(0)
        print_with_color("Open Hadoop Admin Web(node1)")
        open_web("http://node1:50070")

    elif arg == 'yarn':
        # 打开YARN状态界面
        # 8088端口, rm1见yarn-site.xml
        res = os.popen("yarn rmadmin -getServiceState rm1 | grep active").read();
        for line in res.split('\n'):
            if line == 'active':
                print_with_color("Open Yarn Status Web(node0)")
                open_web("http://node0:8088")
                sys.exit(0)
        print_with_color("Open Yarn Status Web(node5)")
        open_web("http://node5:8088")

    elif arg == 'hbase':
        # 打开HBase管理界面
        # 16010端口见hbase-site.xml
        res = os.popen("/opt/hbase/bin/get-active-master.rb | grep node1").read();
        for line in res.split('\n'):
            if line == 'node1':
                print_with_color("Open Hbase Admin Web(node1)")
                open_web("http://node1:16010")
                sys.exit(0)
        print_with_color("Open Hbase Admin Web(node5)")
        open_web("http://node5:16010")

    elif arg == 'ha-doc':
        open_web("file:///opt/hadoop/share/doc/hadoop/index.html")

    elif arg == 'hb-doc':
        open_web("file:///opt/hbase//docs/index.html")

