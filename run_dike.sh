#! /bin/bash

cd spark
./docker/restart_spark.sh

cd ../dikeCS
pwd
./run_dikeCS.sh 

