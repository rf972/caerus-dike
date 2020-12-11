#! /bin/bash

cd spark
./docker/restart_spark_and_nfs.sh

cd ../dikeCS
pwd
./run_dikeCS.sh 

