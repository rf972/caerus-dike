#! /bin/bash
 
CURRENT_TIME=$(date "+%Y-%m-%d_%H-%M-%S")
 
TEST_RESULTS="tpch_results_$CURRENT_TIME.csv"
echo "Output file is: $TEST_RESULTS" 

./run_tpch.py -t 1-22 -a "--test tblFile" --veth --results $TEST_RESULTS
./run_tpch.py -t 1-22 -a "--test tblS3 --s3Filter" --results $TEST_RESULTS
./run_tpch.py -t 1-22 -a "--test tblS3 --s3Filter --s3Project" --results $TEST_RESULTS
./run_tpch.py -t 1-22 -a "--test tblS3 --s3Select" --results $TEST_RESULTS

./run_tpch.py -t 1-22 -a "--test tblPartS3 --s3Filter" --results $TEST_RESULTS
./run_tpch.py -t 1-22 -a "--test tblPartS3 --s3Filter --s3Project" --results $TEST_RESULTS
./run_tpch.py -t 1-22 -a "--test tblPartS3 --s3Select" --results $TEST_RESULTS

./run_tpch.py -t 1-22 -a "--test tblS3 -p 1" --results $TEST_RESULTS
./run_tpch.py -t 1-22 -a "--test tblHdfs" --results $TEST_RESULTS
./run_tpch.py -t 1-22 -a "--test v2CsvHdfs" --results $TEST_RESULTS
./run_tpch.py -t 1-22 -a "--test csvHdfsDs -p 1" --results $TEST_RESULTS
./run_tpch.py -t 1-22 -a "--test csvHdfsDs" --results $TEST_RESULTS
