#!/bin/bash

docker run --rm -p 4040:4040 -p 6066:6066 -p 7077:7077 -p 8080:8080 \
  --expose 7001 --expose 7002 --expose 7003 --expose 7004 --expose 7005 --expose 7077 --expose 6066 \
  --hostname master \
  --name spark_master \
  -e "MASTER=spark://master:7077" \
  -e "SPARK_CONF_DIR=/conf" \
  -e "SPARK_PUBLIC_DNS=localhost" \
  --mount type=bind,source="$(pwd)"/spark,target=/spark \
  --mount type=bind,source="$(pwd)"/build,target=/build \
  --mount type=bind,source="$(pwd)"/examples,target=/examples \
  -v "$(pwd)"/conf/master:/conf -v "$(pwd)"/data:/tmp/data \
  spark_run bin/spark-class org.apache.spark.deploy.master.Master -h master

  