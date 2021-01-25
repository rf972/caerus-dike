#!/bin/bash

if [ ! -d build ]; then
  mkdir build
  mkdir conf | true
fi

if [ ! -d tpch-data ]; then
  mkdir tpch-data
fi

# Include the setup for our cached local directories. (.m2, .ivy2, etc)
source docker/setup.sh

if [[ "$1" == *"debug"* ]]; then
  echo "Starting build docker. $1"
  echo "run sbt to build"
  DOCKER_NAME="spark_build_$1"
  shift
  
  docker run --rm -it --name $DOCKER_NAME \
    --network dike-net \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)"/examples,target=/examples \
    --entrypoint /bin/bash -w /spark \
  -v "${ROOT_DIR}/build/.m2:${DOCKER_HOME_DIR}/.m2" \
  -v "${ROOT_DIR}/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg" \
  -v "${ROOT_DIR}/build/.sbt:${DOCKER_HOME_DIR}/.sbt" \
  -v "${ROOT_DIR}/build/.cache:${DOCKER_HOME_DIR}/.cache" \
  -v "${ROOT_DIR}/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2" \
  -u "${USER_ID}" \
  "spark-build-${USER_NAME}" $@ 
elif [[ "$1" == "incremental" ]]; then
  echo "starting incremental build with sbt"
  
  docker run --rm -it --name spark-incremental \
    --network dike-net \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)"/examples,target=/examples \
    -w /spark \
  -v "${ROOT_DIR}/build/.m2:${DOCKER_HOME_DIR}/.m2" \
  -v "${ROOT_DIR}/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg" \
  -v "${ROOT_DIR}/build/.sbt:${DOCKER_HOME_DIR}/.sbt" \
  -v "${ROOT_DIR}/build/.cache:${DOCKER_HOME_DIR}/.cache" \
  -v "${ROOT_DIR}/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2" \
  -u "${USER_ID}" \
  "spark-build-${USER_NAME}" $@ 
else
  echo "Starting build for $@"	
  cd docker
  ./build_dockers.sh
  cd ..

  docker run --rm -it --name spark_build \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)"/examples,target=/examples \
  -v "${ROOT_DIR}/build/.m2:${DOCKER_HOME_DIR}/.m2" \
  -v "${ROOT_DIR}/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg" \
  -v "${ROOT_DIR}/build/.sbt:${DOCKER_HOME_DIR}/.sbt" \
  -v "${ROOT_DIR}/build/.cache:${DOCKER_HOME_DIR}/.cache" \
  -v "${ROOT_DIR}/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2" \
  -u "${USER_ID}" \
  "spark-build-${USER_NAME}" $@
fi
