#!/bin/bash

set -e
#set -x
echo $1

if [ "$1" == "plugin" ]; then
    echo "Building plugin"
    cd /spark-select
    sbt --ivy /build/ivy compile
    sbt --ivy /build/ivy package
    exit $?
fi
if [ "$1" == "incremental" ]; then
    echo "Building spark incrementally with sbt"
    cd /spark
    sbt package
    exit $?
fi

echo "Building spark"

# Start fresh, so remove the spark home directory.
rm -rf $SPARK_HOME

# Build Spark
cd $SPARK_SRC

# Only build spark if it was requested, since it takes so long.
if [ "$1" == "spark" ]; then
  rm $SPARK_SRC/spark-*SNAPSHOT*.tgz || true 
  ./dev/make-distribution.sh --name custom-spark --pip --tgz
fi

if [ ! -d $SPARK_BUILD ]; then
  echo "Creating Build Directory"
  mkdir $SPARK_BUILD
fi

if [ ! -d $SPARK_BUILD/spark-events ]; then
  mkdir $SPARK_BUILD/spark-events
fi

# Install Spark.
# Extract our built package into our install directory.
echo "Extracting $SPARK_PACKAGE.tgz -> $SPARK_HOME"
tar -xzf $SPARK_SRC/spark-*SNAPSHOT*.tgz -C $SPARK_BUILD \
 && mv $SPARK_BUILD/$SPARK_PACKAGE $SPARK_HOME \
 && mv $SPARK_HOME/jars/httpclient-4.5.6.jar $SPARK_HOME/jars/httpclient-4.5.6.jar.old \
  && chown -R root:root $SPARK_HOME

# Download jar dependencies needed for using S3
# We do this to avoid using the --packages argument to spark-submit.
# Instead we will use --jars /build/extra_jars/*
# This avoids the extra time to run ivy for all dependencies.
#
SPARK_DOWNLOADS=${SPARK_BUILD}/downloads
if [ ! -d $SPARK_DOWNLOADS ]; then
  echo "Creating Downloads Directory"
  mkdir $SPARK_DOWNLOADS
fi
cd $SPARK_DOWNLOADS
if [ ! -f "aws-java-sdk.zip" ]; then
    echo "Downloading aws-java-sdk.zip.  Please be patient."
    wget -nv http://sdk-for-java.amazonwebservices.com/latest/aws-java-sdk.zip
    wget -nv https://repo1.maven.org/maven2/org/apache/commons/commons-csv/1.8/commons-csv-1.8.jar
    mkdir $SPARK_BUILD/extra_jars || true
    cp ./commons-csv*.jar $SPARK_BUILD/extra_jars
else
    echo "Using existing aws-java-sdk.zip"
fi

unzip -n -q aws-java-sdk.zip \
  && cp ./aws-java-sdk-*/third-party/lib/*.jar $SPARK_BUILD/extra_jars \
  && cp ./aws-java-sdk-*/lib/aws*.jar $SPARK_BUILD/extra_jars \
  && rm -rf ./aws-java-sdk-*

if [ ! -f "h2-1.4.200.jar" ]; then
    echo "downloading h2-1.4.200.jar"
    wget -nv https://repo1.maven.org/maven2/com/h2database/h2/1.4.200/h2-1.4.200.jar
fi	

# Build scala examples  
if [ ! -d "/examples/scala/lib" ]; then
  echo "Creating lib Directory"
  mkdir /examples/scala/lib
fi
cd /examples/scala
cp ../../spark/dist/jars/*.jar ./lib
sbt package


