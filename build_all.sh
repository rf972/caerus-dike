#!/bin/bash
set -e
set -x

cd minio/docker
./build_dockers.sh
cd ../
echo "Built minio docker"

./build_server.sh
echo "Built minio server"
cd ../

cd minio/ndp/sqlite
mkdir build || true
cd build
#  Run the configure script
../configure
#  Build the "amalgamation" source file
make sqlite3.c
echo "Built sqlite server"

cd ../../dikeSQL
./build.sh
echo "Built dikeSQL server"
cd ../../../

cd mc/docker
./build_dockers.sh
cd ..
./build_mc.sh
echo "Built mc"
cd ..

cd spark
./build.sh
echo "Built spark"
cd ..

cd s3datasource
./build_s3.sh
echo "Built s3datasource"
cd ..

cd benchmark/tpch
./build_tpch.sh
echo "Built tpch"
cd ../../

echo "Done building Dike all"
#cd spark-select
#./build.sh
#cd ..
#echo "Built spark-select"
