#!/bin/bash

cd benchmark/tpch
mkdir ../../data | true
./build_tbl.sh ../../data || (echo "*** init tpch data failed with $?" ; exit 1)
cd ../../

