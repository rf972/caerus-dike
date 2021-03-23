#! /bin/bash

if [ ! -d data ]; then
  ./init_tpch.sh || (echo "*** failed int of tpch $?" ; exit 1)
fi

pushd dikeHDFS
./hadoop/start.sh bin/start-hadoop.sh || (echo "*** failed start of hadoop $?" ; exit 1)

echo "Waiting for hadoop to start"

sleep 10
./run_init_tpch.sh ../data || (echo "*** failed init of tpch for hdfs $?" ; exit 1)
popd

