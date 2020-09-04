#!/bin/bash

if [ ! -d data ]; then
  mkdir data
fi

docker run -p 9000:9000 \
  -e "MINIO_ACCESS_KEY=admin" \
  -e "MINIO_SECRET_KEY=admin123" \
  --mount type=bind,source="$(pwd)"/data,target=/data \
  --mount type=bind,source="$(pwd)"/build,target=/build \
  --network dike-net \
  --name minioserver \
  --rm \
  minio_run_server server /data

  