#!/bin/bash

rm -rf build

cd tpch-spark/dbgen
make clean
cd ../../
echo "Done cleaning tpch-dbgen"

rm -rf tpch-spark/lib
rm -rf tpch-spark/target
rm -rf tpch-spark/project/target
rm -rf tpch-spark/project/project
rm -rf tpch-spark/.bsp
echo "Done cleaning tpch-spark"

echo "Done cleaning tpch"
