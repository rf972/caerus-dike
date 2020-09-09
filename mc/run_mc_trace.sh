#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker run \
  --mount type=bind,source=$SOURCE/build,target=/build \
  --network dike-net \
  --name minio_trace \
  --rm \
  -it \
  mc_run "$@"

  