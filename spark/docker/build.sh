#!/bin/bash

set -e
#set -x

if [ "$1" == "plugin" ]; then
    echo "Building plugin"
    cd /spark-select
    sbt --ivy /build/ivy compile
    sbt --ivy /build/ivy package
    exit $?
else
    echo "Building spark"
fi
# Start fresh, so remove the spark home directory.
rm -rf $SPARK_HOME

# Build Spark
cd ${SPARK_SRC}
./dev/make-distribution.sh --name custom-spark --pip --tgz

if [ ! -d $SPARK_BUILD ]; then
  echo "Creating Build Directory"
  mkdir $SPARK_BUILD
fi

# Install Spark.
# Extract our built package into our install directory.
  echo "Extracting $SPARK_PACKAGE.tgz -> $SPARK_HOME"
tar -xzf ${SPARK_SRC}/$SPARK_PACKAGE.tgz -C ${SPARK_BUILD} \
 && mv ${SPARK_BUILD}/$SPARK_PACKAGE $SPARK_HOME \
 && wget -N -nv -P $SPARK_HOME/jars https://repo1.maven.org/maven2/org/apache/httpcomponents/httpclient/4.5.12/httpclient-4.5.12.jar \
  && mv $SPARK_HOME/jars/httpclient-4.5.6.jar $SPARK_HOME/jars/httpclient-4.5.6.jar.old \
  && chown -R root:root $SPARK_HOME

