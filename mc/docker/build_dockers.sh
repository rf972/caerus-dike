#!/bin/bash

docker build -f Dockerfile.mc_build -t mc_build .

docker build -f Dockerfile.mc_run -t mc_run .

docker build -f Dockerfile.mc_debug -t mc_debug .

echo "Done"
