#! /bin/bash
set -e

./run_tpch.py -t 1-22 -a "--test tblPartS3 --check"
./run_tpch.py -t 1-14,16-21 -a "--test tblPartS3 --s3Select --check"
./run_tpch.py -t 1-22 -a "--test tblPartS3 --s3Filter --s3Project --check"

./run_tpch.py -t 1-22 -a "--test tblS3 --check"
./run_tpch.py -t 1-14,16-21 -a "--test tblS3 --s3Select --check"
./run_tpch.py -t 1-22 -a "--test tblS3 --s3Filter --s3Project --check"

./run_tpch.py -t 1-22 -a "--test tblS3 -p 1 --check"
./run_tpch.py -t 1-14,16-21 -a "--test tblS3 --s3Select -p 1 --check"
./run_tpch.py -t 1-22 -a "--test tblS3 --s3Filter --s3Project -p 1 --check"

./diff_tpch.py --terse 
