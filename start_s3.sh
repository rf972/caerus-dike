#! /bin/bash

if [ ! -d data ]; then
  ./init_tpch.sh || (echo "*** failed int of tpch $?" ; exit 1)
fi

cd dikeCS
./start.sh || (echo "*** failed int of dikeCS $?" ; exit 1)
