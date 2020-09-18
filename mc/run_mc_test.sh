#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cp docker/run-mc-entrypoint.sh $SOURCE/build

cp test/* $SOURCE/build/test

docker run \
  --mount type=bind,source=$SOURCE/build,target=/build \
  --network dike-net \
  --name minio_cli \
  --rm \
  mc_run "$@"

  