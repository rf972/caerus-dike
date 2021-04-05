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

import org.slf4j.LoggerFactory

import org.apache.spark.Partition
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.sql.{SaveMode, SparkSession}
import org.apache.spark.sql.functions._
import org.apache.spark.sql.types._

/** A set of experiments for our S3 datasource functionality.
 *  The purpose of this is to have a test we can experiment with.
 *  You will see examples of commented out experiments below.
 */
object DatasourceS3Tests {
  val disablePushdown = false
  protected val logger = LoggerFactory.getLogger(getClass)
  def checkRowResult(expected: String, received: String) {
    checkResult(expected, received)
  }
  def checkResult(expected: String, received: String) {
    if (expected != received) {
      logger.error("expected: " + expected + " != received: " + received)
      throw new RuntimeException("expected: != received: ")
    }
    logger.info("RESULT: " + expected)
  }

  def integerExample(args: Array[String]) {
    if (args.length == 0) {
        logger.error("missing arg for s3 ip addr")
        System.exit(1)
    }
    val s3IpAddr = args(0)

    val schema = new StructType()
       .add("i", IntegerType, true)
       .add("j", IntegerType, true)
       .add("k", IntegerType, true)
    val sparkSession = SparkSession.builder
      .master("local[2]")
      .appName("example")
      .config("spark.datasource.pushdown.endpoint", s"""http://$s3IpAddr:9000""")
      .config("spark.datasource.pushdown.accessKey", "admin")
      .config("spark.datasource.pushdown.secretKey", "admin123")
      .getOrCreate()
    sparkSession.sparkContext.setLogLevel("INFO")

    import sparkSession.implicits._

    val df = if (disablePushdown) {
        sparkSession.read
        .format("com.github.datasource")
        .schema(schema)
        .option("format", "csv")
        .load("s3a://spark-test/s3_ints.tbl")
      } else {
        sparkSession.read
        .format("com.github.datasource")
        .schema(schema)
        .option("format", "csv")
        .option("DisableFilterPush", "")
        .option("DisableProjectPush", "")
        .option("DisableAggregatePush", "")
        .load("s3a://spark-test/s3_ints.tbl")
      }
    df.createOrReplaceTempView("integers")
    df.agg(countDistinct("j", "k")).show()
    df.agg(countDistinct("i")).show()
    sparkSession.stop()
  }
  def main(args: Array[String]) {
    integerExample(args)
  }
}
