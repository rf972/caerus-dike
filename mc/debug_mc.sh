#!/bin/bash

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cp $SOURCE/docker/*-mc-entrypoint.sh ./build
chmod a+x ./build/*-mc-entrypoint.sh

git log --format=%H -n1 $SOURCE/mc > $SOURCE/mc/commit_hash

docker run \
  --mount type=bind,source=$SOURCE/build,target=/build \
  --mount type=bind,source=$SOURCE,target=/build/go/src/mc \
  --network dike-net \
  --name minio_cli \
  --rm \
  --publish 40000:40000 --security-opt=seccomp:unconfined \
  -it \
  mc_debug  "$@"

  