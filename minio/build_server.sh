#!/bin/bash

if [ ! -d build ]; then
  mkdir build
fi

git log --format=%H -n1 "$(pwd)"/minio > "$(pwd)"/minio/commit_hash

cp docker/*-entrypoint.sh ./build
chmod a+x ./build/*-entrypoint.sh

docker run \
    --mount type=bind,source="$(pwd)",target=/build/go/src/minio \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    minio_build_server

    