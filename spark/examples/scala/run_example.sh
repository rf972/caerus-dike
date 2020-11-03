#!/bin/bash

if [ "$1" == "debug" ]; then
  echo "Debugging"
  docker exec -it sparkmaster spark-submit --master local \
  --class io.s3.datasource.tests.S3DatasourceTests \
  --conf "spark.jars.ivy=/build/ivy" \
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-3.1.0/jars/*:/examples/scala/target/scala-2.12/ -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=172.18.0.3:5005" \
  --packages com.amazonaws:aws-java-sdk:1.11.853,org.apache.hadoop:hadoop-aws:3.2.0,org.apache.commons:commons-csv:1.8 \
  --jars /s3datasource/target/scala-2.12/s3datasource_2.12-0.1.0.jar \
  /examples/scala/target/scala-2.12/spark-examples_2.12-1.0.jar minioserver
else
  docker exec -it sparkmaster spark-submit --master local \
  --class io.s3.datasource.tests.S3DatasourceTests \
  --conf "spark.jars.ivy=/build/ivy" \
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-3.1.0/jars/*:/examples/scala/target/scala-2.12/" \
  --packages org.apache.httpcomponents:httpcore:4.4.11,com.amazonaws:aws-java-sdk:1.11.853,org.apache.hadoop:hadoop-aws:3.2.0,org.apache.commons:commons-csv:1.8 \
  --jars /s3datasource/target/scala-2.12/s3datasource_2.12-0.1.0.jar \
  /examples/scala/target/scala-2.12/spark-examples_2.12-1.0.jar minioserver
fi
