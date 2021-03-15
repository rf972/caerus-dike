#! /bin/bash

cd spark
./docker/restart_spark.sh
cd ..

if [ ! -d data ]; then
  ./init_tpch.sh
fi

cd dikeHDFS
./start_server.sh
