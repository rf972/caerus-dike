#!/bin/bash


cd benchmark/tpch
printf "\nNext Test: Spark TPC-H query with HDFS storage and with pushdown enabled.\n"
read -n 1 -s -r -p "Press any key to continue with test."
./run_tpch.sh -l -t 14 -ds spark --protocol hdfs --format parquet --pushRule --compression ZSTD --compLevel 2
printf "\nTest Complete: Spark TPC-H query with HDFS storage and with pushdown enabled.\n"

printf "\nNext Test: Spark TPC-H query with HDFS storage (Spark only)\n"
read -n 1 -s -r -p "Press any key to continue with test."
./run_tpch.sh -l -t 14 -ds spark --protocol hdfs --format parquet
printf "\nTest Complete: Spark TPC-H query with HDFS storage (Spark only)\n"

