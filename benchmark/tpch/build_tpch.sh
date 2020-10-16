#!/bin/bash
if [ ! -d tpch-spark/build ]; then
  mkdir tpch-spark/build
fi
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
