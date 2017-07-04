#!/usr/bin/python3
# -*- coding: utf-8 -*-

def print_with_color(txt):
    """
    带有颜色的打印
    """
    print('\033[1;34;1m')
    print(txt)
    print('\033[0m')
