#! /bin/bash

cd spark
./docker/restart_spark.sh
cd ..

cd benchmark/tpch
mkdir ../../data | true
./build_tbl.sh ../../data || (echo "*** build tbl failed with $?" ; exit 1)

cd ../dikeCS
pwd
./run_dikeCS.sh 

