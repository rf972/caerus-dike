package io.s3.datasource.example

import org.apache.spark.Partition
import org.apache.spark.sql.{SaveMode, SparkSession}
import org.apache.spark.sql.types._

object S3DatasourceExample {

  def main(args: Array[String]) { 
    if (args.length == 0) {
        println("missing arg for s3 ip addr") 
        System.exit(1)
    }
    val s3IpAddr = args(0)

    val schema = new StructType()
       .add("id",IntegerType,true)
       .add("name",StringType,true)
       .add("age",IntegerType,true)
       .add("city",StringType,true)

    val sparkSession = SparkSession.builder
      .master("local[2]")
      .appName("example")
      .config("spark.datasource.s3.endpoint", s"""http://$s3IpAddr:9000""")
      .config("spark.datasource.s3.accessKey", "admin")
      .config("spark.datasource.s3.secretKey", "admin123")
      .getOrCreate()

    val df = sparkSession.read
      .format("org.apache.spark.sql.execution.datasources.v2.s3")
      .schema(schema)
      .option("format", "csv")
      .load("s3a://spark-test/s3_data.csv")

    df.show()
    df.filter("id > 0").filter("age > 40").show()

    val count = df.filter("id > 0").filter("age > 40").count()
    println("count is: " + count)
    //df.select(df("id"),df("city"),df("id")).filter(df.name.like("jim")).filter("age > 40").show()
    
    sparkSession.stop()
  }


  def main1(args: Array[String]) {

    val schema = new StructType()
        .add("id",IntegerType,true)
        .add("name",StringType,true)
        .add("age",IntegerType,true)
        .add("city",StringType,true)


    val sparkSession = SparkSession.builder
      .master("local[2]")
      .appName("example")
      .getOrCreate()

    val simpleDf = sparkSession.read
      .format("com.dike.spark.sources.datasourcev2.simple")
      .schema(schema)
      .load("s3a://spark-test/s3_data.csv")

    simpleDf.show()
    println("number of partitions in simple source is " + simpleDf.rdd.getNumPartitions)
    sparkSession.stop()
  }
}
