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
package org.apache.spark.sql.jdbc.example

import java.sql.{Connection, DriverManager}
import java.util.Properties

import org.apache.spark.sql.{SaveMode, SparkSession}
import org.apache.spark.sql.execution.datasources.v2.jdbc.JDBCTableCatalog
import org.apache.spark.sql.functions._
import org.apache.spark.util.Utils
// h2-latest.jar needed to run this test.

/** This is heavily borrowed from JDBCV2Suite.scala from spark.
 *  The purpose of this is to have a test we can experiment with.
 *  You will see examples of commented out experiments below in
 *  the h2Test().
 */
object UnitTest {

  def main(args: Array[String]) {

    h2Test()
  }

  val tempDir = Utils.createTempDir()
  val url = s"jdbc:h2:${tempDir.getCanonicalPath};user=testUser;password=testPass"
  val clName: String = classOf[JDBCTableCatalog].getName
  val sparkSession = SparkSession.builder
      .master("local[2]")
      .appName("example")
      .config("spark.sql.catalog.h2", clName)
      .config("spark.sql.catalog.h2.url", url)
      .config("spark.sql.catalog.h2.driver", "org.h2.Driver")
      .getOrCreate()

  private def withConnection[T](f: Connection => T): T = {
    val conn = DriverManager.getConnection(url, new Properties())
    try {
      f(conn)
    } finally {
      conn.close()
    }
  }

  def setupDatabase(): Unit = {
    withConnection { conn =>
      conn.prepareStatement("CREATE SCHEMA \"test\"").executeUpdate()
      conn.prepareStatement(
        "CREATE TABLE \"test\".\"empty_table\" (name TEXT(32) NOT NULL, id INTEGER NOT NULL)")
        .executeUpdate()
      conn.prepareStatement(
        "CREATE TABLE \"test\".\"people\" (name TEXT(32) NOT NULL, id INTEGER NOT NULL)")
        .executeUpdate()
      conn.prepareStatement("INSERT INTO \"test\".\"people\" VALUES ('fred', 1)").executeUpdate()
      conn.prepareStatement("INSERT INTO \"test\".\"people\" VALUES ('mary', 2)").executeUpdate()
      conn.prepareStatement(
        "CREATE TABLE \"test\".\"employee\" (dept INTEGER, name TEXT(32), salary NUMERIC(20, 2)," +
          " bonus NUMERIC(6, 2))").executeUpdate()
      conn.prepareStatement("INSERT INTO \"test\".\"employee\" VALUES (1, 'amy', 10000, 1000)")
        .executeUpdate()
      conn.prepareStatement("INSERT INTO \"test\".\"employee\" VALUES (2, 'alex', 12000, 1200)")
        .executeUpdate()
      conn.prepareStatement("INSERT INTO \"test\".\"employee\" VALUES (1, 'cathy', 9000, 1200)")
        .executeUpdate()
      conn.prepareStatement("INSERT INTO \"test\".\"employee\" VALUES (2, 'david', 10000, 1300)")
        .executeUpdate()
    }
  }
  def h2Test() : Unit = {

    setupDatabase()
    import sparkSession.implicits._

    val df = sparkSession.sql("select SUM(DEPT) FROM h2.test.employee")
    df.show()
    val df1 = sparkSession.sql("select SUM(DISTINCT DEPT) FROM h2.test.employee")
    df1.show()
  }
}
