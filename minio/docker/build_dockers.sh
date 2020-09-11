#!/bin/bash

docker build -f Dockerfile.minio_build_server -t minio_build_server .

docker build -f Dockerfile.minio_run_server -t minio_run_server .

docker build -f Dockerfile.minio_debug_server -t minio_debug_server .

echo "Done"
