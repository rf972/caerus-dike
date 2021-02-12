#!/bin/bash

if [ "$1" == "debug" ]; then
  echo "Debugging"
  docker exec -it sparkmaster spark-submit --master local \
  --class org.apache.spark.sql.jdbc.example.UnitTest \
  --conf "spark.jars.ivy=/build/ivy" \
  --conf "spark.shuffle.service.enabled=false" \
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-3.2.0/jars/*:/examples/scala/target/scala-2.12/ -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=172.18.0.2:5005" \
  --jars /build/h2-latest.jar \
  /examples/scala/target/scala-2.12/spark-examples_2.12-1.0.jar minioserver
else
  docker exec -it sparkmaster spark-submit --master local \
  --class org.apache.spark.sql.jdbc.example.UnitTest \
  --conf "spark.jars.ivy=/build/ivy" \
  --conf "spark.shuffle.service.enabled=false" \
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-3.2.0/jars/*:/examples/scala/target/scala-2.12/" \
  --jars /build/extra_jars/*,/build/downloads/h2-1.4.200.jar\
  /examples/scala/target/scala-2.12/spark-examples_2.12-1.0.jar minioserver
#  --jars /build/sqlite-jdbc-3.32.3.2.jar,/build/mariadb-java-client-2.6.2.jar \
fi
