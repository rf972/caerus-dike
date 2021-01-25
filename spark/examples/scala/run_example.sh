#!/bin/bash

if [ "$1" == "debug" ]; then
  echo "Debugging"
  docker exec -it sparkmaster spark-submit --master local \
  --class com.github.datasource.tests.DatasourceHdfsTests \
  --conf "spark.jars.ivy=/build/ivy" \
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-3.2.0/jars/*:/examples/scala/target/scala-2.12/ -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=172.18.0.3:5005" \
  --packages com.github.scopt:scopt_2.12:4.0.0-RC2 \
  --jars /dikeHDFS/client/dikeclient/target/dikeclient-1.0-jar-with-dependencies.jar,/build/extra_jars/*,/pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar,/build/downloads/h2-1.4.200.jar\
  /examples/scala/target/scala-2.12/spark-examples_2.12-1.0.jar minioserver

#  --packages org.apache.httpcomponents:httpcore:4.4.11,org.apache.httpcomponents:httpclient:4.5.11,com.amazonaws:aws-java-sdk:1.11.853,org.apache.hadoop:hadoop-aws:3.2.0,org.apache.commons:commons-csv:1.8 \
#  --jars /pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar \
else
  docker exec -it sparkmaster spark-submit --master local \
  --class com.github.datasource.tests.DatasourceHdfsTests \
  --conf "spark.jars.ivy=/build/ivy" \
  --conf "spark.driver.extraJavaOptions=-classpath /conf/:/build/spark-3.2.0/jars/*:/examples/scala/target/scala-2.12/" \
  --packages com.github.scopt:scopt_2.12:4.0.0-RC2 \
  --jars /dikeHDFS/client/dikeclient/target/dikeclient-1.0-jar-with-dependencies.jar,/build/extra_jars/*,/pushdown-datasource/target/scala-2.12/pushdown-datasource_2.12-0.1.0.jar,/build/downloads/h2-1.4.200.jar\
  /examples/scala/target/scala-2.12/spark-examples_2.12-1.0.jar minioserver
fi
