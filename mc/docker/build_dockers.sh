#!/bin/bash

docker build -f Dockerfile.mc_build -t mc_build .

docker build -f Dockerfile.mc_run -t mc_run .

echo "Done"
