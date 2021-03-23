#! /bin/bash

pushd spark
./stop_spark.sh
popd

pushd dikeHDFS
./hadoop/stop.sh 
popd

pushd dikeCS
./stop.sh
popd

printf "\nAll containers stopped successfully\n"
