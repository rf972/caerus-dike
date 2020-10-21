package io.s3.datasource.example

import org.apache.spark.Partition
import org.apache.spark.sql.{SaveMode, SparkSession}
import org.apache.spark.sql.types._
import org.apache.spark.sql.functions._
import org.apache.spark.SparkContext
import org.apache.spark.SparkConf
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.functions.count
import org.apache.spark.sql.functions.sum
import org.apache.spark.sql.functions.avg
import org.apache.spark.sql.functions.udf

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

    import sparkSession.implicits._

    // .format("org.apache.spark.sql.execution.datasources.v2.s3")
    val df = sparkSession.read
      .format("com.github.s3datasource")
      .schema(schema)
      .option("format", "csv")
      .load("s3a://spark-test/s3_data.tbl")

    df.show()
    if (false) {
      df.select("id", "name").show()
      df.filter("id > 3 OR age > 40").show()
      df.select("id", "name").filter("id > 3 OR age > 40").show()
      df.select("id", "city").filter("id > 3 OR age > 40").show()
      df.select("id", "age").filter("id > 3 OR age > 40").show()
      df.select("name", "age").filter("id > 3 OR age > 40").show()
      df.select("name", "city").filter("id > 3 OR age > 40").show()
      df.select("age", "city").filter("id > 3 OR age > 40").show()
    }
    df.agg(count("*").as("cnt")).show()
    //df.groupBy($"city").agg(count("*").as("cnt")).show()
    //df.groupBy($"city").agg(avg($"age"),count("*").as("cnt")).show()
    // df.filter("id > 3 OR age > 40").select("id", "name").show()
    //df.filter("id > 0 AND age > 40").show()

    if (false) {
      df.filter("id != 0").show()
      df.filter("(id != 0) AND (age != 63)").show()
      df.filter("id > 0").filter("age > 40").show()
      df.select(avg("age"), max("age"), min("age")).show()
      val count = df.filter("id > 3").filter("age > 40").count()
      println("count is: " + count)
      // df.select(df("id"),df("city"),df("id")).filter(col("name").like("jim")).filter("age > 40").show()
    }
    if (false) {
      df.write.option("header", true).format("csv").save("/build/s3_data.csv")
      df.write.option("header", true).format("json").save("/build/s3_data.json")
      df.write.option("header", true).format("parquet").save("/build/s3_data.parquet")
    }
    if (false) {
      val dfj = sparkSession.read
        .format("org.apache.spark.sql.execution.datasources.v2.s3")
        .schema(schema)
        .option("format", "json")
        .load("s3a://spark-test/s3_data.json")
        dfj.show()
    }
    if (false) {
      val dfp = sparkSession.read
        .format("org.apache.spark.sql.execution.datasources.v2.s3")
        .schema(schema)
        .option("format", "parquet")
        .load("s3a://spark-test/s3_data.parquet")
    dfp.show()
    }
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
