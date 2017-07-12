#!/usr/bin/python3
# -*- coding: utf-8 -*-

import webbrowser
import sys

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
        # 50070端口见hdfs-site.xml
        open_web("http://node1:50070")
    elif arg == 'yarn':
        # 打开YARN状态界面
        # 8088端口见yarn-site.xml
        open_web("http://node0:8088")
    elif arg == 'hbase':
        # 打开HBase管理界面
        # 16010端口见hbase-site.xml
        open_web("http://node1:16010")
    elif arg == 'ha-doc':
        open_web("file:///opt/hadoop/share/doc/hadoop/index.html")
    elif arg == 'hb-doc':
        open_web("file:///opt/hbase//docs/index.html")

