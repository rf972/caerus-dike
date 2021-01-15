#!/bin/bash
SPARK_JAR_DIR=../spark/build/spark-3.2.0/jars/
if [ ! -d $SPARK_JAR_DIR ]; then
  echo "Please build spark before building pushdown-datasource"
  exit 1
fi
if [ ! -d pushdown-datasource/lib ]; then
  mkdir pushdown-datasource/lib
fi
cp $SPARK_JAR_DIR/*spark*.jar pushdown-datasource/lib
if [ "$#" -gt 0 ]; then
  if [ "$1" == "debug" ]; then
    echo "Debugging"
    shift
    echo "build with:   sbt"
    docker run --rm -it --name s3_build_debug \
      --mount type=bind,source="$(pwd)"/../pushdown-datasource,target=/pushdown-datasource \
      --entrypoint /bin/bash -w /pushdown-datasource/pushdown-datasource\
      spark_build 
  fi
else
  echo "Building pushdown-datasource"
  docker run --rm -it --name pushdown_datasource_build \
    --mount type=bind,source="$(pwd)"/../pushdown-datasource,target=/pushdown-datasource \
    --entrypoint /pushdown-datasource/scripts/build.sh -w /pushdown-datasource/pushdown-datasource \
    spark_build
fi
