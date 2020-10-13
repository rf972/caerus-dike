#!/bin/bash

# We assume that root is above
SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT="$SOURCE/.."

# Download test file
if [ ! -d $ROOT/build/data ]; then
  mkdir $ROOT/build/data
fi


$ROOT/run_mc.sh minio config host add myminio http://minioserver:9000 admin admin123
$ROOT/run_mc.sh minio mb myminio/tpch-test

for f in nation region supplier customer part partsupp order lineitem
do
    $ROOT/run_mc.sh minio cp /build/data/$f.csv myminio/tpch-test/
done


