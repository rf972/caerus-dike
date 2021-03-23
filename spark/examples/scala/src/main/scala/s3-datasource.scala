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

/** A set of experiments for our S3 datasource functionality.
 *  The purpose of this is to have a test we can experiment with.
 *  You will see examples of commented out experiments below.
 */
object DatasourceS3Tests {
  def checkRowResult(expected: String, received: String) {
    checkResult(expected, received)
  }
  def checkResult(expected: String, received: String) {
    if (expected != received) {
      println("expected: " + expected + " != received: " + received)
      throw new RuntimeException("expected: != received: ")
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
      .config("spark.datasource.pushdown.endpoint", s"""http://$s3IpAddr:9000""")
      .config("spark.datasource.pushdown.accessKey", "admin")
      .config("spark.datasource.pushdown.secretKey", "admin123")
      .getOrCreate()
    //sparkSession.sparkContext.setLogLevel("TRACE")

    import sparkSession.implicits._

    // .format("org.apache.spark.sql.execution.datasources.v2.s3")
    val df = sparkSession.read
      .format("com.github.datasource")
      .schema(schema)
      .option("format", "csv")
      /*.option("DisableFilterPush", "")
      .option("DisableProjectPush", "")
      .option("DisableAggregatePush", "") */
      .load("s3a://spark-test/s3_ints.tbl")
    df.createOrReplaceTempView("integers")

    //sparkSession.sql("SELECT count(*) FROM integers").show()
    //df.show()    
    //query.explain("extended")

    //df.agg(countDistinct("j", "k")).show()
    df.agg(countDistinct("j", "k")).show()
    df.agg(countDistinct("i")).show()
    /*sparkSession.sql("SELECT count(*) FROM integers").show()
    sparkSession.sql("SELECT count(i) FROM integers WHERE j = 15").show()
    sparkSession.sql("SELECT count(k) FROM integers WHERE j = 5").show()
    sparkSession.sql("SELECT count(j) FROM integers WHERE k = 2").show()
    sparkSession.sql("SELECT count(k) FROM integers WHERE k = 2 OR j = 5").show()
    sparkSession.sql("SELECT count(k,j) FROM integers WHERE k = 2 OR j = 5").show()
    df.groupBy("k").agg(count("j"), count("i")).show()
    df.groupBy("j").agg(count("j"), count("i")).show() 
    df.agg(countDistinct("j", "k"), countDistinct("i"), countDistinct("i","j")).show()
    df.agg(countDistinct("i", "j", "k")).show()*/
    //df.agg(count("j"), count("i")).show()
    //var df9 = df.groupBy("j").agg(sum("i").as("total_ints")).filter("total_ints > 1")
    //df9.show()
    //df9.explain(true)
    /*
    df.groupBy("j").agg(sum("i").as("sumofi"))
      .sort($"sumofi".desc, $"j").show()
    df.groupBy("j").agg(sum("i").as("sumofi"))
      .sort($"sumofi".desc, $"j").explain(true)
    checkRowResult(Seq(Row(5, 12), Row(10, 9)).mkString(","),
                   df.groupBy("j").agg(sum("i")).collect.mkString(","))
    checkRowResult(Seq(Row(12), Row(9)).mkString(","),
                   sparkSession.sql("SELECT sum(i) FROM integers GROUP BY j").collect.mkString(","))
    checkRowResult(Seq(Row(5, 12), Row(10, 9)).mkString(","),
                   sparkSession.sql("SELECT j, sum(i) FROM integers GROUP BY j").collect.mkString(","))
    checkRowResult(Seq(Row(12, 5), Row(9, 10)).mkString(","),
                   sparkSession.sql("SELECT sum(i), j FROM integers GROUP BY j").collect.mkString(","))
    checkRowResult(Seq(Row(4, 5, 12, 1), Row(6, 10, 9, 2)).mkString(","),
                   sparkSession.sql("SELECT sum(k), j, sum(i), min(k) FROM integers GROUP BY j")
                               .collect.mkString(","))
    var q1 = sparkSession.sql("SELECT sum(i), j, sum(k), min(k) FROM integers WHERE i > 1" +
                                    " GROUP BY j")
    q1.explain(true)
    q1.show()
    q1 = sparkSession.sql("SELECT sum(k), j, sum(i), min(k) FROM integers WHERE i > 1" +
                                    " GROUP BY j")
    q1.explain(true)
    q1.show()
    checkRowResult(Seq(Row(12, 5, 3, 1), Row(8, 10, 4, 2)).mkString(","),
                   sparkSession.sql("SELECT sum(i), j, sum(k), min(k) FROM integers WHERE i > 1" +
                                    " GROUP BY j")
                               .collect.mkString(","))
     checkRowResult(Seq(Row(5, 15),Row(10, 40)).mkString(","),
                   sparkSession.sql("SELECT j, sum(k * j) FROM integers WHERE i > 1" +
                                    " GROUP BY j")
                               .collect.mkString(","))
     checkRowResult(Seq(Row(15, 5),Row(40, 10)).mkString(","),
                   sparkSession.sql("SELECT sum(k * j), j FROM integers WHERE i > 1" +
                                    " GROUP BY j")
                               .collect.mkString(","))*/

    /* group by multiple j,k */

     /*checkRowResult(Seq(Row(1, 15, 5, 1),Row(2, 40, 10, 2)).mkString(","),
                   sparkSession.sql("SELECT k, sum(k * j), j, k FROM integers WHERE i > 1" +
                                    " GROUP BY j, k")
                               .collect.mkString(","))*/

    /* filter of groups "HAVING" */
    /*
     checkRowResult(Seq(Row(15),Row(40)).mkString(","),
                   sparkSession.sql("SELECT sum(k * j) FROM integers WHERE i > 1" +
                                    " GROUP BY j")
                               .collect.mkString(","))
     checkRowResult(Seq(Row(5, 6),Row(10, 18)).mkString(","),
                   sparkSession.sql("SELECT j, sum(i * k) FROM integers WHERE i != 6" +
                                    " GROUP BY j")
                               .collect.mkString(","))                               
    checkRowResult(Seq(Row(18),Row(24)).mkString(","),
                   sparkSession.sql("SELECT sum(k + j) FROM integers WHERE i > 1" +
                                    " GROUP BY j")
                               .collect.mkString(","))
    checkRowResult(Seq(Row(165)).mkString(","),
                   df.filter("i > 4")
                     .agg(sum("i") * sum("j")).collect.mkString(",")) 
    checkRowResult(Seq(Row(50)).mkString(","),
                   df.agg(sum("j")).collect.mkString(","))
    checkRowResult(Seq(Row(1, 2)).mkString(","),
                   df.agg(min("k"), max("k")).collect.mkString(","))
    checkRowResult(Seq(Row(15, 5, 10, 7.5)).mkString(","),
                   df.filter("i > 4")
                     .agg(sum("j"), min("j"), max("j"), avg("j")).collect.mkString(","))
    checkRowResult(Seq(Row(15, 5, 7.5, 10)).mkString(","),
                   df.filter("i > 4")
                     .agg(sum("j"), min("j"), avg("j"), max("j")).collect.mkString(","))
    checkRowResult(Seq(Row(21, 0, 6, 3.0)).mkString(","),
                   df.agg(sum("i"), min("i"), max("i"), avg("i")).collect.mkString(","))
    checkRowResult(Seq(Row(0, 5, 1), Row(1, 10, 2), Row(2, 5, 1),
                       Row(3, 10, 2), Row(4, 5, 1), Row(5, 10, 2), Row(6, 5, 1)).mkString(","),
                   df.select("i","j","k").collect.mkString(","))
    checkRowResult(Seq(Row(0, 5), Row(1, 10), Row(2, 5),
                       Row(3, 10), Row(4, 5), Row(5, 10), Row(6, 5)).mkString(","),
                   df.select("i","j").collect.mkString(","))
    checkRowResult(Seq(Row(5,10,2),Row(6,5,1)).mkString(","),
                   df.filter("i >= 5").collect.mkString(","))  */
    //checkResult("1", df.filter("i == 0").count().toString)
    //df.groupBy("j").agg(count($"i")).show()
    sparkSession.stop()
  }
  def main(args: Array[String]) { 
    integerExample(args)
  }
}
