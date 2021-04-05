#! /bin/bash

pushd spark
./start_spark.sh || (echo "*** failed start of spark $?" ; exit 1)
popd

./start_hdfs.sh
./start_s3.sh

printf "\nSuccessfully started all servers.\n"
