#!/bin/bash
if [ "$#" -gt 0 ]; then
  if [ "$1" == "debug" ]; then
    echo "Debugging"
    shift
    echo "build with:   sbt --ivy /s3datasource/build/ivy/"
    docker run --rm -it --name s3_build_debug \
      --mount type=bind,source="$(pwd)"/../s3datasource,target=/s3datasource \
      --mount type=bind,source="$(pwd)"/../../spark,target=/spark \
      --entrypoint /bin/bash -w /s3datasource/s3datasource\
      spark_build 
  fi
else
  echo "Building s3datasource"
  docker run --rm -it --name s3_build \
    --mount type=bind,source="$(pwd)"/../s3datasource,target=/s3datasource \
    --mount type=bind,source="$(pwd)"/../../spark,target=/spark \
    --entrypoint /s3datasource/build/build.sh -w /s3datasource/s3datasource \
    spark_build
fi
