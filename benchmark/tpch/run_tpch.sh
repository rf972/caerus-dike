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
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-3.2.0/jars/*:/examples/scala/target/scala-2.12/ -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=172.18.0.4:5005" \
  --packages com.github.scopt:scopt_2.12:4.0.0-RC2 \
  --jars /build/extra_jars/*,/pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar,/build/downloads/h2-1.4.200.jar \
  /tpch/tpch-spark/target/scala-2.12/spark-tpc-h-queries_2.12-1.0.jar $@
    #--packages com.github.scopt:scopt_2.12:4.0.0-RC2,com.amazonaws:aws-java-sdk:1.11.853,org.apache.hadoop:hadoop-aws:3.2.0,org.apache.commons:commons-csv:1.8 \
else
  # --master local
  docker exec -it sparkmaster spark-submit --master local[1] \
  --num-executors 1 --executor-cores 1 \
  --conf "log4j.rootCategory=WARN,console" \
  --conf "ivy.shared.default.root=/build/ivy_jars" \
  --conf "spark.driver.extraClassPath=/build/extra_jars/*" \
  --conf "spark.executor.extraClassPath=/build/extra_jars/*" \
  --conf "spark.jars.ivy=/build/ivy" \
  --conf "spark.driver.maxResultSize=20g" \
  --conf "spark.driver.memory=20g" \
  --conf "spark.eventLog.enabled=true" \
  --conf "spark.eventLog.dir=/build/spark-events" \
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-3.2.0/jars/*:/examples/scala/target/scala-2.12/" \
  --packages com.github.scopt:scopt_2.12:4.0.0-RC2 \
  --jars /build/extra_jars/*,/pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar,/build/downloads/h2-1.4.200.jar\
  /tpch/tpch-spark/target/scala-2.12/spark-tpc-h-queries_2.12-1.0.jar $@
#  --packages com.github.scopt:scopt_2.12:4.0.0-RC2,com.amazonaws:aws-java-sdk:1.11.853,org.apache.hadoop:hadoop-aws:3.2.0,org.apache.commons:commons-csv:1.8 \
#  --conf "spark.files.maxPartitionBytes=16777216" \
#  --conf "spark.sql.files.maxPartitionBytes=16777216" \
#  --jars /build/extra_jars/*,/pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar,/build/h2-latest.jar \
fi

STATUS=$?
if [ $STATUS -eq 0 ];then
  echo "TPCH Successful"
else
  echo "TPCH Failed"
fi
