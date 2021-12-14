#!/bin/bash

CORES="$1"
T1="$2"
T2="$3"
echo "$CORES $T1 $T2"

./scripts/client.py 10.124.48.87 Spark_Q${T1}_${CORES}_cores ; ./run_tpch.sh -w ${CORES} -t ${T1} -ds spark --protocol hdfs --format parquet --path tpch-test-parquet-400g
./scripts/client.py 10.124.48.87 NDP_Q${T1}_${CORES}_cores ; ./run_tpch.sh -w ${CORES} -t ${T1} -ds spark --protocol hdfs --format parquet --pushRule --compression ZSTD --compLevel 2 --path tpch-test-parquet-400g
./scripts/client.py 10.124.48.87 Spark_Q${T2}_${CORES}_cores ; ./run_tpch.sh -w ${CORES} -t ${T2} -ds spark --protocol hdfs --format parquet --path tpch-test-parquet-400g ;
./scripts/client.py 10.124.48.87 NDP_Q${T2}_${CORES}_cores ; ./run_tpch.sh -w ${CORES} -t ${T2} -ds spark --protocol hdfs --format parquet --pushRule --compression ZSTD --compLevel 2 --path tpch-test-parquet-400g
./scripts/client.py 10.124.48.87 Spark_Q${T1}_Q${T2}_${CORES}_cores ; ./run_tpch.sh -w ${CORES} -t ${T1},${T2} -ds spark --protocol hdfs --format parquet --path tpch-test-parquet-400g --mode parallel;
./scripts/client.py 10.124.48.87 NDP_Q${T1}_Q${T2}_${CORES}_cores ; ./run_tpch.sh -w ${CORES} -t ${T1},${T2} -ds spark --protocol hdfs --format parquet --pushRule --compression ZSTD --compLevel 2 --path tpch-test-parquet-400g --mode parallel
