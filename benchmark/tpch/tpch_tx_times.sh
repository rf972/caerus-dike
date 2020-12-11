#! /bin/bash

./run_tpch.py -t 1-22 -a "--test tblS3 -p 1" ; ./run_tpch.py -t 1-22 -a "--test tblS3 --s3Filter -p 1"; ./run_tpch.py -t 1-22 -a "--test tblS3 --s3Filter --s3Project -p 1" ; ./run_tpch.py -t 1-14,16-21 -a "--test tblS3 --s3Select -p 1"
