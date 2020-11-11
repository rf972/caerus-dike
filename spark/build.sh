#!/bin/bash

if [ ! -d build ]; then
  mkdir build
  mkdir conf | true
fi

if [ ! -d tpch-data ]; then
  mkdir tpch-data
fi
cp ./.sbtopts spark
if [[ "$1" == *"debug"* ]]; then
  echo "Starting build docker. $1"
  echo "run sbt to build"
  DOCKER_NAME="spark_build_$1"
  shift
  
  docker run --rm -it --name $DOCKER_NAME \
    --network dike-net \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)"/examples,target=/examples \
    --entrypoint /bin/bash -w /spark \
    spark_build $@ 
elif [[ "$1" == "incremental" ]]; then
  echo "starting incremental build with sbt"
  
  docker run --rm -it --name spark-incremental \
    --network dike-net \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)"/examples,target=/examples \
    -w /spark \
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
