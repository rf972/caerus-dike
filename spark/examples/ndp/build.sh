#!/bin/bash

if [ ! -d ./examples/ndp/lib ]; then
    mkdir ./examples/ndp/lib
fi

DIKEJAR=../dikeHDFS/client/ndp-hdfs/target/ndp-hdfs-1.0-jar-with-dependencies.jar
if [ ! -f $DIKEJAR ]; then
  echo "Please build dikeHDFS ($DIKEJAR) before building ndp examples"
  exit 1
fi
cp $DIKEJAR ./examples/ndp/lib
echo "Copying $DIKEJAR"

if [ ! -d ./examples/ndp/build ]; then
    mkdir ./examples/ndp/build
    mkdir examples/ndp/build/
    mkdir examples/ndp/build/.sbt
    mkdir examples/ndp/build/.m2
    mkdir examples/ndp/build/.gnupg
    mkdir examples/ndp/build/.cache
    mkdir examples/ndp/build/.ivy2
fi
# Bring in environment including ${ROOT_DIR} etc.
source docker/setup.sh

if [[ "$1" == *"debug"* ]]; then
  echo "Starting build docker. $1"
  echo "run sbt to build"
  DOCKER_NAME="ndp_build_$1"
  shift

  docker run --rm -it --name $DOCKER_NAME \
    --network dike-net \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)"/examples/ndp,target=/ndp \
    -v "${ROOT_DIR}/examples/ndp/build/.m2:${DOCKER_HOME_DIR}/.m2" \
    -v "${ROOT_DIR}/examples/ndp/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg" \
    -v "${ROOT_DIR}/examples/ndp/build/.sbt:${DOCKER_HOME_DIR}/.sbt" \
    -v "${ROOT_DIR}/examples/ndp/build/.cache:${DOCKER_HOME_DIR}/.cache" \
    -v "${ROOT_DIR}/examples/ndp/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2" \
    -u "${USER_ID}" \
    --entrypoint /bin/bash -w /ndp \
    "spark-build-${USER_NAME}"
else
  echo "starting incremental build with sbt"
  
  docker run --rm -it --name ndp-example-build \
    --network dike-net \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)"/examples/ndp,target=/ndp \
    -v "${ROOT_DIR}/examples/ndp/build/.m2:${DOCKER_HOME_DIR}/.m2" \
    -v "${ROOT_DIR}/examples/ndp/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg" \
    -v "${ROOT_DIR}/examples/ndp/build/.sbt:${DOCKER_HOME_DIR}/.sbt" \
    -v "${ROOT_DIR}/examples/ndp/build/.cache:${DOCKER_HOME_DIR}/.cache" \
    -v "${ROOT_DIR}/examples/ndp/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2" \
    -u "${USER_ID}" \
    -w /ndp \
    --entrypoint /bin/bash "spark-build-${USER_NAME}" -c "sbt package"
fi
