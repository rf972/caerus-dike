#! /bin/bash

./run_tpch.py -t 1-22 -a "--test tblFile" --veth
./run_tpch.py -t 1-22 -a "--test tblS3 --s3Filter"
./run_tpch.py -t 1-22 -a "--test tblS3 --s3Filter --s3Project"
./run_tpch.py -t 1-14,16-21 -a "--test tblS3 --s3Select"

./run_tpch.py -t 1-22 -a "--test tblPartS3 --s3Filter"
./run_tpch.py -t 1-22 -a "--test tblPartS3 --s3Filter --s3Project"
./run_tpch.py -t 1-14,16-21 -a "--test tblPartS3 --s3Select"
