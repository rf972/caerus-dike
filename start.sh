#! /bin/bash

mkdir ./data || true
pushd spark
./start_spark.sh || (echo "*** failed start of spark $?" ; exit 1)
popd

./start_hdfs.sh

printf "\nSuccessfully started all servers.\n"
