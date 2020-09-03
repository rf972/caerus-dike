#!/bin/bash

docker run \
  --mount type=bind,source="$(pwd)"/build,target=/build \
  --network dike-net \
  --name minio_cli \
  --rm \
  mc_run "$@"

  