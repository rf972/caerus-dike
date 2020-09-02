FROM ubuntu:20.04 as builder_base
LABEL version="1.0"

RUN apt-get update \
 && apt-get install -y locales \
 && dpkg-reconfigure -f noninteractive locales \
 && locale-gen en_US.UTF-8 \
 && /usr/sbin/update-locale LANG=en_US.UTF-8 \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Users with other locales should set this in their derivative image
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata \
 && apt-get install -y wget curl unzip nano vim \
    python3 python3-setuptools \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && apt install -y python3-pip \
 && python3 -mpip install py4j \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# JAVA
RUN apt-get update \
 && apt install default-jdk scala git maven -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Setup Spark Environment
ENV SPARK_VERSION 3.1.0
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-SNAPSHOT-bin-custom-spark
ENV SPARK_SRC /spark
ENV SPARK_BUILD /build
ENV SPARK_HOME ${SPARK_BUILD}/spark-${SPARK_VERSION}
#ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:${SPARK_HOME}/bin
ENV echo "export SPARK_HOME=/opt/spark" >> ~/.profile
ENV echo "export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin" >> ~/.profile
ENV echo "export PYSPARK_PYTHON=/usr/bin/python3" >> ~/.profile

# Configure maven to save artifacts under build
ENV mkdir /root/.m2 | true
COPY ./settings.xml /root/.m2/settings.xml

####
#### Spark build docker stage.
####
FROM builder_base as builder
LABEL version="1.0"

ADD build.sh /build.sh
RUN chmod +x /build.sh
CMD ["/build.sh"]

####
#### Spark run docker stage.
####
FROM builder_base as run
LABEL version="1.0"

WORKDIR $SPARK_HOME
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]