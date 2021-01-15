#!/bin/bash
SPARK_JAR_DIR=../spark/build/spark-3.2.0/jars/
if [ ! -d $SPARK_JAR_DIR ]; then
  echo "Please build spark before building s3datasource"
  exit 1
fi
if [ ! -d s3datasource/lib ]; then
  mkdir s3datasource/lib
fi
cp $SPARK_JAR_DIR/*spark*.jar s3datasource/lib
if [ "$#" -gt 0 ]; then
  if [ "$1" == "debug" ]; then
    echo "Debugging"
    shift
    echo "build with:   sbt"
    docker run --rm -it --name s3_build_debug \
      --mount type=bind,source="$(pwd)"/../s3datasource,target=/s3datasource \
      --entrypoint /bin/bash -w /s3datasource/s3datasource\
      spark_build 
  fi
else
  echo "Building s3datasource"
  docker run --rm -it --name s3_build \
    --mount type=bind,source="$(pwd)"/../s3datasource,target=/s3datasource \
    --entrypoint /s3datasource/scripts/build.sh -w /s3datasource/s3datasource \
    spark_build
fi
