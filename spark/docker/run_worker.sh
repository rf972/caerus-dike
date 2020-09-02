#!/bin/bash

docker run --rm -p 8081:8081 \
  --expose 7012 --expose 7013 --expose 7014 --expose 7015 --expose 8881 \
  --hostname worker \
  --name spark_worker \
  --link="spark_master" \
  -e "SPARK_CONF_DIR=/conf" \
      -e "SPARK_WORKER_CORES=2" \
      -e "SPARK_WORKER_MEMORY=1g" \
      -e "SPARK_WORKER_PORT=8881" \
      -e "SPARK_WORKER_WEBUI_PORT=8081" \
      -e "SPARK_PUBLIC_DNS=localhost" \
  --mount type=bind,source="$(pwd)"/spark,target=/spark \
  --mount type=bind,source="$(pwd)"/build,target=/build \
  -v "$(pwd)"/conf/worker:/conf -v "$(pwd)"/data:/tmp/data \
  spark_run bin/spark-class org.apache.spark.deploy.worker.Worker spark://master:7077

