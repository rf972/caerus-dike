#!/bin/bash
set -e
set -x

cd spark
./build.sh
echo "Built spark"
cd ..

cd s3datasource
./build_s3.sh
echo "Built s3datasource"
cd ..

cd benchmark/tpch
./build_tbl.sh ../../minio/data
./build_tpch.sh
echo "Built tpch"
cd ../../

cd dikeCS
git submodule init
git submodule update --recursive
cd external
./build_aws.sh
cd ..
./build.sh
echo "Built dikeCS"
cd ..

echo "Done building Dike all"

