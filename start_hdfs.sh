#! /bin/bash

if [ ! -d data ]; then
  ./init_tpch.sh || (echo "*** failed int of tpch $?" ; exit 1)
fi

pushd dikeHDFS
./start_server.sh || (echo "*** failed start of hadoop $?" ; exit 1)

echo "Waiting for hadoop to start"

sleep 30
./disable_safe_mode.sh
./run_init_tpch.sh ../data || (echo "*** failed init of tpch for hdfs $?" ; exit 1)
popd

