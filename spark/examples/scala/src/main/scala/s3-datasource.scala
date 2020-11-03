package io.s3.datasource.tests

import java.lang.RuntimeException
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
import org.scalatest.Assertions._

import org.apache.spark.sql.Row

object S3DatasourceTests {
  def checkRowResult(expected: String, received: String) {
    checkResult(expected, received)
  }
  def checkResult(expected: String, received: String) {
    if (expected != received) {
      throw new RuntimeException("expected: " + expected + " != received: " + received)
    }
    println("RESULT: " + expected)
  }
  def integerExample(args: Array[String]) { 
    if (args.length == 0) {
        println("missing arg for s3 ip addr") 
        System.exit(1)
    }
    val s3IpAddr = args(0)
  
    val schema = new StructType()
       .add("i",IntegerType,true)
       .add("j",IntegerType,true)
       .add("k",IntegerType,true)
    val sparkSession = SparkSession.builder
      .master("local[2]")
      .appName("example")
      .config("spark.datasource.s3.endpoint", s"""http://$s3IpAddr:9000""")
      .config("spark.datasource.s3.accessKey", "admin")
      .config("spark.datasource.s3.secretKey", "admin123")
      .getOrCreate()
    // sparkSession.sparkContext.setLogLevel("TRACE")

    import sparkSession.implicits._

    // .format("org.apache.spark.sql.execution.datasources.v2.s3")
    val df = sparkSession.read
      .format("com.github.s3datasource")
      .schema(schema)
      .option("format", "csv")
      .load("s3a://spark-test/s3_ints_3.tbl")

    //query.show()    
    //query.explain("extended")
    checkRowResult(Seq(Row(50)).mkString(","),
                   df.agg(sum("j")).collect.mkString(","))
    checkRowResult(Seq(Row(1, 2)).mkString(","),
                   df.agg(min("k"), max("k")).collect.mkString(","))
    checkRowResult(Seq(Row(15, 5, 10, 7.5)).mkString(","),
                   df.filter("i > 4")
                     .agg(sum("j"), min("j"), max("j"), avg("j")).collect.mkString(","))
    checkRowResult(Seq(Row(21, 0, 6, 3.0)).mkString(","),
                   df.agg(sum("i"), min("i"), max("i"), avg("i")).collect.mkString(","))
    checkRowResult(Seq(Row(0, 5, 1), Row(1, 10, 2), Row(2, 5, 1),
                       Row(3, 10, 2), Row(4, 5, 1), Row(5, 10, 2), Row(6, 5, 1)).mkString(","),
                   df.select("i","j","k").collect.mkString(","))
    checkRowResult(Seq(Row(0, 5), Row(1, 10), Row(2, 5),
                       Row(3, 10), Row(4, 5), Row(5, 10), Row(6, 5)).mkString(","),
                   df.select("i","j").collect.mkString(","))
    checkRowResult(Seq(Row(5,10,2),Row(6,5,1)).mkString(","),
                   df.filter("i >= 5").collect.mkString(","))
    checkResult("1", df.filter("i == 0").count().toString)
    //df.groupBy("j").agg(sum("i"),sum("j"),sum("k")).explain("extended")
    //df.groupBy("j").agg(sum("i"),sum("j"),sum("k")).show()
    //df.groupBy("j").agg(count($"i")).show()
    // df.filter("i > 3").groupBy("j").agg(sum($"i")).where(sum("i") > 10)
    sparkSession.stop()
  }  
  def peopleExample(args: Array[String]) { 
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
    // sparkSession.sparkContext.setLogLevel("TRACE")

    import sparkSession.implicits._

    val df = sparkSession.read
      .format("com.github.s3datasource")
      .schema(schema)
      .option("format", "csv")
      .load("s3a://spark-test/s3_data.tbl")
    df.show()
    //df.agg(count($"id")).show()
    //df.groupBy($"city").agg(count($"id")).show()
    //df.groupBy($"city").agg(sum($"age")).show()
    //df.filter("id > 3 OR age > 40").show()
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

  def main(args: Array[String]) { 

    integerExample(args)
    //peopleExample(args)
  }
}
