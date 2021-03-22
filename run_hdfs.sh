#! /bin/bash

cd spark
./docker/restart_spark.sh
cd ..

if [ ! -d data ]; then
  ./init_tpch.sh
fi

pushd dikeHDFS
./hadoop/start.sh bin/start-hadoop.sh
popd

