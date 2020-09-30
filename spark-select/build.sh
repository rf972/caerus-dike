#!/bin/bash

if [ ! -d build ]; then
  mkdir build
fi

docker run --rm -it --name spark-select-build \
    --mount type=bind,source="$(pwd)"/spark-select,target=/spark-select \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    spark_build spark-select

    
