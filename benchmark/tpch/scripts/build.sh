#! /bin/sh

echo "Building tpch"
cd /tpch/tpch-spark
sbt package

echo "Building tpch Complete"
exit $?
