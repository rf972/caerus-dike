#!/bin/bash

if [ ! -d build ]; then
  mkdir build
  mkdir conf | true
fi

docker run --rm -it --name spark-build-interactive \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)"/examples,target=/examples \
    --entrypoint /bin/bash -w /spark \
    spark_build $@
