#!/bin/bash

docker run -it --rm  \
-p 9000:9000 \
-v "$(pwd)/build":/build \
-v "$(pwd)/../minio/data":/data \
--network dike-net \
--name dikeS3 \
ubuntu:20.04 "$@"
