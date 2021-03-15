#!/bin/bash
set -e

cd tpch-spark/dbgen
make || (echo "*** build dbgen failed with $?" ; exit 1)
cd ../../

./build_tpch.sh || (echo "*** build tpch failed with $?" ; exit 1)

