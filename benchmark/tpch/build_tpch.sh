#!/bin/bash

if [ "$1" == "debug" ]; then
  echo "Debugging"
  shift
  docker run --rm -it --name tpch_build_debug \
    --mount type=bind,source="$(pwd)"/../tpch,target=/tpch \
    --mount type=bind,source="$(pwd)"/../../spark,target=/spark \
    --entrypoint /bin/bash -w /tpch/tpch-spark \
    spark_build 
else
  docker run --rm -it --name tpch_build \
    --mount type=bind,source="$(pwd)"/../tpch,target=/tpch \
    --mount type=bind,source="$(pwd)"/../../spark,target=/spark \
    --entrypoint /tpch/build/build.sh \
    spark_build 
fi
