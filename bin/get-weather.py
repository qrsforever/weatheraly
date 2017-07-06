#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
下载国家气象局所有气候数据
"""

import os
import re
import threading
from ftplib import FTP  
from time import sleep

def ftp_get_data(tid, n, step):
    # year: 1901 - 2017
    #  pattern = r"[12][09][0-9]{2}"
    start = n
    end = n + step - 1
    if n == 1:
        start = 0
    pattern = "[12][09][{}-{}][0-9]".format(start, end)
    print(pattern)
    match_year = re.compile(pattern)
    
    # 下载路径
    # 采集站点编号: ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-history.txt
    output = "noaa"
    # BEIJING,SHANGHAI,TIANJIN,JINAN,WASHINGTON,LONDON,TOKYO
    ids = "545110|583620|545270|548230|725117|726230|476620"
    if not os.path.exists(output):
        os.mkdir(output)
    else:
        print("{} is exists".format(output))
    
    while True:
        try: 
            with FTP() as ftp:
                ftp.set_debuglevel(2)
                ftp.connect("ftp.ncdc.noaa.gov", 21, 60)
                ftp.login() # 匿名登录(user=anonymous, passwd='')
                ftp.getwelcome()
                ftp.cwd("pub/data/noaa/")
                ftp.set_debuglevel(0)
                
                files = ftp.nlst()
                for name in files:
                    result = match_year.match(name)
                    if result is not None:
                        for gzfile in ftp.nlst(name):
                            #  print("[thread-{}] check {}".format(tid, gzfile))
                            ret = re.search(ids, gzfile)
                            if ret is None:
                                continue
                            year_dir = output + "/" + name
                            if not os.path.exists(year_dir):
                                os.mkdir(year_dir)
                            outfile = output + "/" + gzfile
                            if os.path.exists(outfile):
                                continue
                            print("[thread-{}]Downloading:{} ".format(tid, gzfile))
                            with open(outfile, 'wb') as f:
                                ftp.retrbinary("RETR " + gzfile, f.write, 2048)
                # 下载气候文件格式说明文档
                formatdoc = "ish-format-document.pdf"
                doc = output + "/" + formatdoc
                if not os.path.exists(doc):
                   with open(doc, "wb") as f:
                       ftp.retrbinary("RETR " + formatdoc, f.write, 1024)
                break
        except Exception as err:
            print(err)
            sleep(3)


if __name__ == "__main__":
    # ftp 服务器最大允许2个线程访问
    threads = []
    step = 5
    nloops = range(0, 9, step)
    for i in nloops:
       t = threading.Thread(target=ftp_get_data, args = (i, i, step))
       threads.append(t)
    for t in threads:
       t.start()
    for t in threads:
       t.join()
