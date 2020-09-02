#!/bin/bash

docker build -f Dockerfile --target builder -t spark_build .
echo "Done building spark_build docker"

docker build -f Dockerfile -t spark_run .
echo "Done building spark_run docker"

echo "Done building dockers"