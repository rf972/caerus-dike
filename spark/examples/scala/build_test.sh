#!/bin/bash

SPARK_JAR_DIR=./build/spark-3.2.0/jars/
if [ ! -d $SPARK_JAR_DIR ]; then
  echo "Please build spark ($SPARK_JAR_DIR) before building spark examples"
  exit 1
fi
if [ ! -d ./examples/scala/lib ]; then
    mkdir ./examples/scala/lib
fi
cp $SPARK_JAR_DIR/*spark*.jar ./examples/scala/lib
S3JAR=../pushdown-datasource/pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar
if [ ! -f $S3JAR ]; then
  echo "Please build pushdown-datasource ($S3JAR) before building spark examples"
  exit 1
fi
cp $S3JAR ./examples/scala/lib

DIKECLIENTJAR=../dikeHDFS/client/dikeclient/target/dikeclient-1.0-jar-with-dependencies.jar
if [ ! -f $DIKECLIENTJAR ]; then
  echo "Please build dikeHDFS client ($DIKECLIENTJAR) before building spark examples"
  exit 1
fi
cp $DIKECLIENTJAR ./examples/scala/lib
echo "Copying $DIKECLIENTJAR"

# Bring in environment including ${ROOT_DIR} etc.
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
    -v "${ROOT_DIR}/build/.m2:${DOCKER_HOME_DIR}/.m2" \
    -v "${ROOT_DIR}/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg" \
    -v "${ROOT_DIR}/build/.sbt:${DOCKER_HOME_DIR}/.sbt" \
    -v "${ROOT_DIR}/build/.cache:${DOCKER_HOME_DIR}/.cache" \
    -v "${ROOT_DIR}/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2" \
    -u "${USER_ID}" \
    --entrypoint /bin/bash -w /examples/scala \
    "spark-build-${USER_NAME}"
else
  echo "starting incremental build with sbt"
  
  docker run --rm -it --name spark-incremental \
    --network dike-net \
    --mount type=bind,source="$(pwd)"/spark,target=/spark \
    --mount type=bind,source="$(pwd)"/build,target=/build \
    --mount type=bind,source="$(pwd)"/examples,target=/examples \
    -v "${ROOT_DIR}/build/.m2:${DOCKER_HOME_DIR}/.m2" \
    -v "${ROOT_DIR}/build/.gnupg:${DOCKER_HOME_DIR}/.gnupg" \
    -v "${ROOT_DIR}/build/.sbt:${DOCKER_HOME_DIR}/.sbt" \
    -v "${ROOT_DIR}/build/.cache:${DOCKER_HOME_DIR}/.cache" \
    -v "${ROOT_DIR}/build/.ivy2:${DOCKER_HOME_DIR}/.ivy2" \
    -u "${USER_ID}" \
    -w /examples/scala \
    --entrypoint /bin/bash "spark-build-${USER_NAME}" -c "sbt package"
fi
