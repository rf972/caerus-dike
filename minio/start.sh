#! /bin/bash

set -e

echo "Setting up permissions for minio"
docker exec -it dikehdfs bin/hdfs dfs -chmod -R 777 /
docker exec -it dikehdfs bin/hdfs dfs -ls /

printf "\nStarting minio S3 gateway in detached mode ...\n"
DAEMONIZE="-d=true"
DOCKER_CMD="docker run --rm=true ${DAEMONIZE} \
            -e \"MINIO_ROOT_USER=admin\" \
            -e \"MINIO_ROOT_PASSWORD=admin123\" \
            --name minioserver --hostname minioserver \
            --network dike-net \
            minio/minio:RELEASE.2021-01-16T02-19-44Z gateway hdfs hdfs://dikehdfs:9000"

eval "$DOCKER_CMD" || (echo "*** failed start of minio docker $?" ; exit 1)
echo "minio started successfully"
