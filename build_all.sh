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

cd spark
./build.sh
cd ../
echo "Built spark"

cd spark-select
./build.sh
cd ..
echo "Built spark-select"

cd mc/docker
./build_dockers.sh
cd ../
./build_mc.sh
echo "Built mc"
