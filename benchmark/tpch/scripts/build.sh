#! /bin/sh

echo "Building tpch"
cd /tpch/tpch-spark
cp ../../../s3datasource/s3datasource/target/scala-2.12/s3datasource_2.12-0.1.0.jar lib
sbt package

echo "Building tpch Complete"
exit $?
