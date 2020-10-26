#!/bin/bash

if [ ! -d data ]; then
  mkdir data
fi

cp docker/*-entrypoint.sh ./build
chmod a+x ./build/*-entrypoint.sh

docker run \
  -e "MINIO_ACCESS_KEY=admin" \
  -e "MINIO_SECRET_KEY=admin123" \
  -e "USE_DIKE_SQL=1" \
  --mount type=bind,source="$(pwd)"/data,target=/data \
  --mount type=bind,source="$(pwd)"/build,target=/build \
  --network dike-net \
  --name minioserver \
  --rm \
  -it \
  minio_run_server minio server /data

  