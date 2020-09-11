#!/bin/bash

if [ ! -d data ]; then
  mkdir data
fi

cp docker/*-entrypoint.sh ./build
chmod a+x ./build/*-entrypoint.sh

git log --format=%H -n1 "$(pwd)"/minio > "$(pwd)"/minio/commit_hash

docker run -p 9000:9000 \
  -e "MINIO_ACCESS_KEY=admin" \
  -e "MINIO_SECRET_KEY=admin123" \
  --mount type=bind,source="$(pwd)"/data,target=/data \
  --mount type=bind,source="$(pwd)",target=/build/go/src/minio \
  --mount type=bind,source="$(pwd)"/build,target=/build \
  --network dike-net \
  --name minioserver \
  --rm \
  --publish 40000:40000 --security-opt=seccomp:unconfined \
  -it \
  minio_debug_server server /data

  