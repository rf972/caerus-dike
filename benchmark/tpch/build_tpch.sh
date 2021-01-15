#!/bin/bash
if [ ! -d tpch-spark/lib ]; then
  mkdir tpch-spark/lib
fi
if [ ! -d tpch-spark/build ]; then
  mkdir tpch-spark/build
fi
SPARK_JAR_DIR=../../spark/build/spark-3.2.0/jars/
if [ ! -d $SPARK_JAR_DIR ]; then
  echo "Please build spark ($SPARK_JAR_DIR) before building s3datasource"
  exit 1
fi
cp $SPARK_JAR_DIR/*spark*.jar tpch-spark/lib
S3JAR=../../s3datasource/s3datasource/target/scala-2.12/s3datasource_2.12-0.1.0.jar

if [ ! -f $S3JAR ]; then
  echo "Please build s3datasource ($S3JAR) before building tpch-spark"
  exit 1
fi
cp $S3JAR tpch-spark/lib
if [ "$1" == "debug" ]; then
  echo "Debugging"
  shift
  docker run --rm -it --name tpch_build_debug \
    --mount type=bind,source="$(pwd)"/../tpch,target=/tpch \
    --entrypoint /bin/bash -w /tpch/tpch-spark \
    spark_build 
else
  docker run --rm -it --name tpch_build \
    --mount type=bind,source="$(pwd)"/../tpch,target=/tpch \
    --entrypoint /tpch/scripts/build.sh \
    spark_build 
fi
