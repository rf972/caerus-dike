#!/bin/bash

if [ ! -d build ]; then
  mkdir build
  mkdir conf | true
fi

if [ ! -d tpch-data ]; then
  mkdir tpch-data
fi

if [ "$1" == "debug" ]; then
  echo "Starting build docker."
  echo "run sbt to build"
  shift
  
  docker run --rm -it --name spark_build_interactive \
    --network dike-net \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)"/examples,target=/examples \
    --entrypoint /bin/bash -w /spark \
    spark_build $@ 
else  
  cd docker
  ./build_dockers.sh
  cd ..

  docker run --rm -it --name spark_build \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)"/examples,target=/examples \
    spark_build $@
fi
