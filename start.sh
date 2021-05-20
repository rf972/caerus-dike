#! /bin/bash

mkdir ./data 2>&1 > /dev/null || true
pushd spark
./start.sh || (echo "*** failed start of spark $?" ; exit 1)
popd

./start_hdfs.sh

printf "\nSuccessfully started all servers.\n"
