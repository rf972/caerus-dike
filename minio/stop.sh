#! /bin/bash

set -e
printf "\nStopping minio S3 gateway ...\n"
DOCKER_CMD="docker stop minioserver"
eval "$DOCKER_CMD" || (echo "*** failed stop of minio docker $?" ; exit 1)
echo "minio stopped successfully"