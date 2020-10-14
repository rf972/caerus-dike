#!/bin/bash

docker run                              \
  -v "$(pwd)/../data":/data             \
  -v "$(pwd)/exports":/etc/exports:ro   \
  --cap-add SYS_ADMIN                   \
  --privileged                          \
  --network dike-net                    \
  --rm --name nfsserver -d              \
  erichough/nfs-server

 