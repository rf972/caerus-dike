/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
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

/** A set of experiments for our hdfs datasource functionality.
 *  The purpose of this is to have a test we can experiment with.
 *  You will see examples of commented out experiments below.
 */
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
    sparkSession.sparkContext.setLogLevel("INFO")
    import sparkSession.implicits._

    /*val df = sparkSession.read
      .format("com.github.datasource")
      .schema(schema)
      .option("format", "csv")
      .option("DisableProcessor", "1")
      .load("ndphdfs://dikehdfs/spark-test/ints.csv")
    df.show()*/

    val csvDF = sparkSession.read
        .format("csv")
        .schema(schema)
        .load("webhdfs://dikehdfs/spark-test/ints.csv").show()

    val df1 = sparkSession.read
      .format("com.github.datasource")
      .schema(schema)
      .option("format", "csv")
      /*.option("DisableFilterPush", "1")
      .option("DisableProjectPush", "1")
      .option("DisableAggregatePush", "1")*/
      .load("ndphdfs://dikehdfs/spark-test/ints.tbl")
    df1.createOrReplaceTempView("integers")

    df1.agg(countDistinct("j", "k"), countDistinct("i")).show()

    /*import org.apache.spark.sql.customUdf._
    val decrease = CustomUDF.register("udf { (x: Double, y: Double) => x * (1 - y) }")
    println(decrease)
    val customUdf = CustomUDF.findUDF(decrease)
    println(customUdf)
    df1.agg(sum(decrease($"i", $"j"))).show()*/


    //df1.show()
    //df1.select("i").filter("k == 1").show()
    /*df1.agg(count("i"),count("j"),count("k")).show()
    df1.agg(count("i"),count("j"),count("k")).explain(true)
    df1.agg(count("i")).explain(true)
    sparkSession.sql("SELECT count(k), k, sum(k * j), j, k FROM integers WHERE i > 1" +
                     " GROUP BY j, k").show()
    sparkSession.sql("SELECT k, sum(k * j), count(k), j, k FROM integers" +
                     " GROUP BY j, k").show()
    df1.agg(count($"j").as("c_count"))
       .sort($"c_count".desc).show()
    sparkSession.sql("SELECT count(k) as c_count, k, sum(k + j), j, k FROM integers WHERE i > 1" +
                     " GROUP BY j,k").show()
    df1.groupBy($"k")
       .agg(count($"k").as("c_count"))
       .show()
    df1.filter("k != 1").agg(countDistinct($"j").as("k_not_one")).show()
    df1.select(countDistinct("j")).show()
    df1.select(countDistinct("j")).explain(true)
    df1.select(countDistinct("j", "k")).show()
    df1.select(countDistinct("j", "k")).explain(true)
    df1.select(countDistinct("i")).show()
    df1.select(countDistinct("i", "j")).show()
    println("count: " + df1.count())
    println("distinct count: " + df1.distinct.count()) 
    sparkSession.sql("SELECT count(k) as c_count, k, sum(k + j), j, k FROM integers WHERE i > 1" +
                 " GROUP BY j,k").show()
    sparkSession.sql("SELECT count(DISTINCT k) as c_count, k, sum(k + j), j, k FROM integers WHERE i > 1" +
                 " GROUP BY j,k").show()
    sparkSession.sql("SELECT count(DISTINCT k, j) as c_count, k, sum(k + j), j, k FROM integers WHERE i > 1" +
                 " GROUP BY j,k").show()*/
    //sparkSession.sql("SELECT count(DISTINCT k, j) FROM integers").show() //explain(true)
    //df1.select(countDistinct("j","k")).show()
  }

  def main(args: Array[String]) {
    integerHdfsExample(args)
  }
}
