#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os
import re
from common_utils import print_with_color

mnt_cmd='sudo mount -o user=lidong,password=1,uid=1000,gid=1000 //{}/workspace /home/lidong/vagrant/{}'
umt_cmd='sudo umount /home/lidong/vagrant/{} >/dev/null'

vag_dir='/home/lidong/vagrant'

if __name__ == "__main__":
    if not os.path.exists(vag_dir):
        os.mkdir(vag_dir)

    pattern = "PING node\d+ \((\d{3}.\d{3}.\d{1,3}.\d{1,3})\) .*? (\d{1}) received, .*?"
    ping = re.compile(pattern, re.S)

    for i in range(1, 6, 1):
        node = 'node' + str(i)
        path = os.path.join(vag_dir, node)
        if not os.path.exists(path):
            os.mkdir(path)

        os.system(umt_cmd.format(node)) 
        text = os.popen("ping -c 1 -W 1 " + node).read()
        res = ping.match(text)
        if res is not None:
            ip = res.group(1)
            cc = res.group(2)
            if cc == '0':
                print_with_color("ping " + node + " fail")
                continue
            print_with_color("mount: " + node)
            os.system(mnt_cmd.format(ip, node)) 
