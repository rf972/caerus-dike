#!/usr/bin/python3

import sys
import os

if len(sys.argv) < 3:
    print("Usage: {} SRC_DIR DST_DIR".format(str(sys.argv[0])))
    exit(1)

SRC_DIR = str(sys.argv[1])
DST_DIR = str(sys.argv[2])

if not os.path.isdir(SRC_DIR) or not os.path.isdir(DST_DIR):
    print("Usage: {} SRC_DIR DST_DIR".format(str(sys.argv[0])))
    exit(1)
