package com.github.datasource.tests

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
import org.apache.spark.sql.catalyst.ScalaReflection
import org.apache.spark.sql.{Dataset, Row}
import scala.reflect.runtime.universe._
import org.apache.spark.sql.Row

import org.apache.hadoop.conf.Configuration

object DatasourceHdfsTests {

  def integerHdfsExample(args: Array[String]) { 
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
      .getOrCreate()
    //sparkSession.sparkContext.setLogLevel("TRACE")
    import sparkSession.implicits._

    val df = sparkSession.read
      .format("com.github.datasource")
      .schema(schema)
      .option("format", "csv")
      .option("DisableProcessor", "1")
      .load("dikehdfs://dikehdfs/spark-test/ints.csv")
    df.show()

    val df1 = sparkSession.read
      .format("com.github.datasource")
      .schema(schema)
      .option("format", "csv")
      .load("dikehdfs://dikehdfs/spark-test/ints.tbl")
    df1.createOrReplaceTempView("integers")
    df1.show()
    df1.select("i").filter("k == 1").show()
  }

  def main(args: Array[String]) {
    integerHdfsExample(args)
  }
}
