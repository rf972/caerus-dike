#!/bin/bash

if [ ! -d build ]; then
  mkdir build
  mkdir conf | true
fi

cd docker
./build_dockers.sh
cd ..

docker run --rm -it --name spark_build \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    spark_build

    
