#! /bin/sh

echo "Building tpch"
cd /tpch/tpch-spark
sbt --ivy /spark/build/ivy package

echo "Building tpch Complete"
exit $?