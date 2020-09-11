#!/bin/bash

if [ ! -d data ]; then
  mkdir data
fi

cp docker/debug-server-entrypoint.sh "$(pwd)"/build

git log --format=%H -n1 "$(pwd)"/minio > "$(pwd)"/minio/commit_hash

docker run -p 9000:9000 \
  -e "MINIO_ACCESS_KEY=admin" \
  -e "MINIO_SECRET_KEY=admin123" \
  --mount type=bind,source="$(pwd)"/data,target=/data \
  --mount type=bind,source="$(pwd)"/build,target=/build \
  --mount type=bind,source="$(pwd)"/minio,target=/minio \
  --network dike-net \
  --name minioserver \
  --rm \
  --publish 40000:40000 --security-opt=seccomp:unconfined \
  -it \
  minio_debug_server 

  