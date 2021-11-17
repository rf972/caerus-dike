#!/bin/bash
for i in {2,4,8,10,12,14,16,18,20}; do echo "Starting $i" ; pushd ../../spark ; ./stop.sh ;  ./start.sh $i ; popd ; ./run_tpch.sh -t 14 -ds spark --protocol file --format parquet ; done
