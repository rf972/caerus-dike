#!/bin/bash

docker run --rm -it --name tpch_build \
    --mount type=bind,source="$(pwd)"/../tpch,target=/tpch \
    --mount type=bind,source="$(pwd)"/../../spark,target=/spark \
    --entrypoint /tpch/build/build.sh \
    spark_build 
