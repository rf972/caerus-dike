#!/bin/bash

if [ ! -d build ]; then
  mkdir build
fi

cp docker/docker-entrypoint.sh ./build

docker run \
    --mount type=bind,source="$(pwd)"/mc,target=/mc \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    mc_build

    