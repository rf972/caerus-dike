'''Use Spark to read from an S3 instance.'''

import operator
import pyspark
import os
import sys
from pyspark.sql import SparkSession

def main(s3_ip_addr):
    #os.environ['PYSPARK_SUBMIT_ARGS'] = "--packages=org.apache.hadoop:hadoop-aws:2.7.3 pyspark-shell"

    #Intialize a spark context
    with pyspark.SparkContext("local", "PySparkWordCount") as sc:

        sc.setLogLevel('WARN')
        hadoopConf = sc._jsc.hadoopConfiguration()
        hadoopConf.set("fs.s3a.access.key", "admin")
        hadoopConf.set("fs.s3a.secret.key", "admin123")
        hadoopConf.set("fs.s3a.endpoint", "http://{}:9000".format(s3_ip_addr))
        hadoopConf.set("fs.s3a.path.style.access", "true")
        hadoopConf.set("fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")

        spark = SparkSession.builder \
                        .appName("Python Spark SQL basic example") \
                        .config("spark.some.config.option", "some-value") \
                        .getOrCreate()
        df = spark.read.option("header",True).csv("s3a://spark-test/s3_data.csv")
        df.printSchema()
        print("rows: {}".format(df.count()))
        df.show()
        df2 = df.select("age","name","id")
        print(df2.collect())
        df2.show()
        df3 = df.select("city","id")
        print(df3.collect())
        df3.show()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("ERROR: missing ip addr of s3 instance")
        print("s3: <ip addr of s3>")
        exit(1)
    ip_addr = sys.argv[1]
    main(ip_addr)
