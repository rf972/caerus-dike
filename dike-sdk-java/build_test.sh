#!/bin/bash

docker run -it --rm  \
-v "$(pwd)/dike-test/s3/SelectObjectContent":/usr/src/mymaven \
-w /usr/src/mymaven \
-v "$(pwd)/build/root/.m2":/root/.m2 \
maven:3.6.3-jdk-11 mvn clean install

