#!/bin/bash

if [ ! -d docker ]; then
  echo "Must run restart_spark.sh from spark directory"
  exit 1
fi
echo "stop spark."
./stop_spark.sh
cd spark
sudo sh ../docker/copy_jars.sh
cd ..
sleep 5
echo "Re-starting spark"
./start_spark.sh
sleep 10
echo "Done restarting Spark"
