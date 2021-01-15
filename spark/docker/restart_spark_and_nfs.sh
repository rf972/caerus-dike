#!/bin/bash

if [ ! -d tpch-data ]; then
  echo "Must run restart_spark_and_nfs.sh from spark directory"
  exit 1
fi
echo "unmount spark/tpch-data and stop spark."
sudo umount tpch-data
./stop_spark.sh
cd spark
sudo sh ../docker/copy_jars.sh
cd ../../minio/nfs_server
docker kill nfsserver
echo "Wait for nfsserver to stop"
sleep 2
./run_nfs_server.sh
echo "Wait for nfsserver to start"
sleep 5
cd ../../spark
echo "Re-mounting spark/tpch-data"
NFSSERVER_IP=$(docker inspect nfsserver | grep IPAddress | cut -d'"' -f4 | sed 's/\n//g' | sed 's/\r//g')
echo "nfsserver IP is: $NFSSERVER_IP"
sudo mount -t nfs4 -o proto=tcp,lookupcache=none  $NFSSERVER_IP:/data $(pwd)/tpch-data
echo "Re-starting spark"
./start_spark.sh
sleep 10
echo "Done restarting Spark"
