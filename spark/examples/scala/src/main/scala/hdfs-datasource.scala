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

import java.io.{BufferedWriter, OutputStreamWriter}
import java.lang.RuntimeException
import java.net.URI
import java.nio.charset.StandardCharsets

import org.apache.commons.io.IOUtils
import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.fs.FileSystem
import org.apache.hadoop.fs.FSDataOutputStream
import org.apache.hadoop.fs.Path
import org.slf4j.LoggerFactory

import org.apache.spark.Partition
import org.apache.spark.SparkConf
import org.apache.spark.SparkContext
import org.apache.spark.sql.{SaveMode, SparkSession}
import org.apache.spark.sql.functions._
import org.apache.spark.sql.types._

/** A set of experiments for our hdfs datasource functionality.
 *  The purpose of this is to have a test we can experiment with.
 *  You will see examples of commented out experiments below.
 */
object DatasourceHdfsTests {
  val disablePushdown = false
  protected val logger = LoggerFactory.getLogger(getClass)

  protected val sparkSession = SparkSession.builder
      .master("local[2]")
      .appName("example")
      .getOrCreate()
  def integerHdfsExample(args: Array[String]) {
    val host = if (args.length == 0) { "dikehdfs" } else { args(0) }

    val schema = new StructType()
       .add("i", IntegerType, true)
       .add("j", IntegerType, true)
       .add("k", IntegerType, true)
    sparkSession.sparkContext.setLogLevel("INFO")
    import sparkSession.implicits._

    // Example of reading a normal csv file from hdfs.
    val csvDF = sparkSession.read
        .format("csv")
        .schema(schema)
        .load(s"webhdfs://${host}/integer-test-csv").show()

    val df1 = if (disablePushdown) {
        // To disable any of the pushdown options, add in options as
        // shown below.  These Disable options can be combined to disable
        // some or all of the pushdowns.
        sparkSession.read
        .format("com.github.datasource")
        .schema(schema)
        .option("format", "tbl")
        .option("DisableFilterPush", "")
        .option("DisableProjectPush", "")
        .option("DisableAggregatePush", "")
        .load(s"ndphdfs://${host}/integer-test/ints.tbl")
    } else {
      // To read with the datasource, include the below options.
      sparkSession.read
      .format("com.github.datasource")
      .schema(schema)
      .option("format", "tbl")
      .load(s"ndphdfs://${host}/integer-test/ints.tbl")
    }
    df1.createOrReplaceTempView("integers")

    df1.agg(countDistinct("j", "k"), countDistinct("i")).show()
  }

  def main(args: Array[String]) {
    val id = new InitData(sparkSession)
    id.init()
    integerHdfsExample(args)
  }
}

/** Allows for initializing the data in hdfs which is used by
 *  the examples.
 */
class InitData(spark: SparkSession) {

  /** Initializes a data frame with the sample data and
   *  then writes this dataframe out to hdfs.
   */
  def initCsv(): Unit = {
    val s = spark
    import s.implicits._
    val testDF = dataValues.toSeq.toDF("i", "j", "k")
    testDF.select("*").repartition(1)
      .write.mode("overwrite")
      .format("csv")
      // .option("header", "true")
      .option("partitions", "1")
      .save("hdfs://dikehdfs:9000/integer-test-csv")
  }
  private val dataValues = Seq((0, 5, 1), (1, 10, 2), (2, 5, 1),
                               (3, 10, 2), (4, 5, 1), (5, 10, 2), (6, 5, 1))
  /** Formats the data with | (pipe) separated format.
   */
  def getData(): String = {
    val sb = new StringBuilder()
    for (r <- dataValues) {
      r.productIterator.map(_.asInstanceOf[Int])
       .foreach(i => sb.append(i + "|"))
      sb.append("\n")
    }
    sb.substring(0)
  }
  /** Writes the sample data out to hdfs.
   */
  def initTbl(): Unit = {
    val conf = new Configuration();
    val url = "hdfs://dikehdfs:9000"
    conf.set("fs.defaultFS", url);

    val fs = FileSystem.get(URI.create(url), conf);

    val dataPath = new Path("/integer-test/ints.tbl");
    val fsStrmData = fs.create(dataPath, true);
    val bWriterData = new BufferedWriter(new OutputStreamWriter(fsStrmData,
                                                                StandardCharsets.UTF_8));
    bWriterData.write(getData);
    bWriterData.close();
    fs.close();
  }
  def init(): Unit = {
    initTbl
    initCsv
  }
}
