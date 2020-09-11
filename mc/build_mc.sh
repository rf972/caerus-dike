#!/bin/bash

if [ ! -d build ]; then
  mkdir build
fi

cp docker/*-mc-entrypoint.sh ./build
chmod a+x ./build/*-mc-entrypoint.sh

docker run \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)",target=/build/go/src/mc \
    mc_build

    