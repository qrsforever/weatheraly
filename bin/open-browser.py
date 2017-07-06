#!/usr/bin/python3
# -*- coding: utf-8 -*-

import webbrowser

handle = webbrowser.get()

# 打开Hadoop管理界面
# 50070端口见hdfs-site.xml
handle.open("http://node1:50070")

# 打开YARN状态界面
# 8088端口见yarn-site.xml
handle.open("http://node0:8088")

# 打开HBase管理界面
# 16010端口见hbase-site.xml
handle.open("http://node1:16010")
