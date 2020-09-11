#!/bin/bash

if [ ! -d build ]; then
  mkdir build
fi

git log --format=%H -n1 "$(pwd)"/minio > "$(pwd)"/minio/commit_hash

docker run \
    --mount type=bind,source="$(pwd)"/minio,target=/minio \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    minio_build_server

    