#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os
import re

M2_REPO = "/home/lidong/.m2/repository"

def copy_file(source, target):
    #  print ("copy form " + source + " to " + target)
    if os.path.isfile(source):
        open(target, "wb").write(open(source, "rb").read())


def copy_hadoop_jars():
    home = os.environ.get("HADOOP_HOME")
    if not os.path.isdir(home):
        print("Not set environ: HADOOP_HOME")
        return
    ver = os.environ.get("HADOOP_VERSION")
    if ver is None:
        ver = "2.7.3"
    m2_hadoop = os.path.join(M2_REPO, "org", "apache", "hadoop")
    ha_share = os.path.join(home, "share", "hadoop")

    for root, dirs, files in os.walk(ha_share):
        for dir in dirs:
            src_dir = os.path.join(root, dir, "sources")
            if not os.path.isdir(src_dir):
                continue
            for file in os.listdir(src_dir):
                r = r"(\w+[-\w]*)-{}-sources.jar".format(ver)
                m = re.match(r, file)
                if m is not None:
                    dst_dir = os.path.join(m2_hadoop, m.group(1), ver)
                    if not os.path.isdir(dst_dir):
                        continue
                    source = os.path.join(src_dir, file)
                    target = os.path.join(dst_dir, file)
                    copy_file(source, target)

    
def main():
    print("main start!")
    copy_hadoop_jars()

if __name__ == "__main__":
    if os.path.isdir(M2_REPO):
        main()
