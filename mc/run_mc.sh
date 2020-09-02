#!/bin/bash

docker run \
  --mount type=bind,source="$(pwd)"/build,target=/build \
  mc_run "$@"

  