#! /bin/sh

echo "Building tpch-spark"
cd /tpch/tpch-spark
sbt package

echo "Building tpch-spark complete"
exit $?
