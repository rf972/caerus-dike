#!/bin/bash
if [ "$#" -lt 1 ]; then
  echo "Usage: [debug] <args for test or --help>"
  exit 1
fi
if [ "$1" == "debug" ]; then
  echo "Debugging"
  shift
  docker exec -it sparkmaster spark-submit --master local \
  --class main.scala.TpchQuery \
  --conf "spark.jars.ivy=/build/ivy" \
  --conf "spark.driver.maxResultSize=20g" \
  --conf "spark.driver.memory=20g" \
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-3.1.0/jars/*:/examples/scala/target/scala-2.12/ -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=172.18.0.3:5005" \
    --packages com.github.scopt:scopt_2.12:4.0.0-RC2,com.amazonaws:aws-java-sdk:1.11.853,org.apache.hadoop:hadoop-aws:3.2.0,org.apache.commons:commons-csv:1.8 \
  /tpch/tpch-spark/target/scala-2.12/spark-tpc-h-queries_2.12-1.0.jar $@
else
  # --master local
  docker exec -it sparkmaster spark-submit --master local[4] \
  --conf "spark.jars.ivy=/build/ivy" \
  --conf "spark.driver.maxResultSize=20g" \
  --conf "spark.driver.memory=20g" \
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-3.1.0/jars/*:/examples/scala/target/scala-2.12/" \
  --packages com.github.scopt:scopt_2.12:4.0.0-RC2,com.amazonaws:aws-java-sdk:1.11.853,org.apache.hadoop:hadoop-aws:3.2.0,org.apache.commons:commons-csv:1.8 \
  /tpch/tpch-spark/target/scala-2.12/spark-tpc-h-queries_2.12-1.0.jar $@
fi

STATUS=$?
if [ $STATUS -eq 0 ];then
  echo "TPCH Successful"
else
  echo "TPCH Failed"
fi
