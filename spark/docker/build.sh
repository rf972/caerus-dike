#!/bin/sh

set -e
set -x

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
tar -xzf ${SPARK_SRC}/$SPARK_PACKAGE.tgz -C ${SPARK_BUILD} \
 && mv ${SPARK_BUILD}/$SPARK_PACKAGE $SPARK_HOME \
 && chown -R root:root $SPARK_HOME

# Download jar dependencies needed for using S3.
SPARK_DOWNLOADS=${SPARK_BUILD}/downloads
if [ ! -d $SPARK_DOWNLOADS ]; then
  echo "Creating Downloads Directory"
  mkdir $SPARK_DOWNLOADS
fi
cd $SPARK_DOWNLOADS
if [ ! -f "aws-java-sdk.zip" ]; then
    echo "Downloading aws-java-sdk.zip"
    wget -nv http://sdk-for-java.amazonwebservices.com/latest/aws-java-sdk.zip
else
    echo "Using existing aws-java-sdk.zip"
fi

unzip -n -q aws-java-sdk.zip \
  && cp ./aws-java-sdk-*/third-party/lib/aws*.jar $SPARK_HOME/jars \
  && cp ./aws-java-sdk-*/lib/aws*.jar $SPARK_HOME/jars \
  && cp ./aws-java-sdk-*/third-party/lib/joda*.jar $SPARK_HOME/jars \
  && cp ./aws-java-sdk-*/third-party/lib/httpclient-*.jar $SPARK_HOME/jars \
  && rm -rf ./aws-java-sdk-*

cd $SPARK_HOME/jars
wget -N -nv https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-core/1.11.375/aws-java-sdk-core-1.11.375.jar \
 && wget -N -nv https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-s3/1.11.375/aws-java-sdk-s3-1.11.375.jar \
 && wget -N -nv https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-kms/1.11.375/aws-java-sdk-kms-1.11.375.jar \
 && wget -N -nv https://repo1.maven.org/maven2/HTTPClient/HTTPClient/0.3-3/HTTPClient-0.3-3.jar \
 && wget -N -nv https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.0/hadoop-aws-3.2.0.jar \
 && wget -N -nv https://repo1.maven.org/maven2/net/java/dev/jets3t/jets3t/0.9.4/jets3t-0.9.4.jar

# We require a newer httpclient to avoid issues due to certain operations.
mv $SPARK_HOME/jars/httpclient-4.5.6.jar $SPARK_HOME/jars/httpclient-4.5.6.jar.old

chown -R root:root $SPARK_HOME