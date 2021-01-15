package org.apache.spark.sql.jdbc.example

import java.sql.{Connection, DriverManager}
import java.util.Properties

import org.apache.spark.sql.catalyst.plans.logical.Filter
import org.apache.spark.sql.execution.datasources.v2.jdbc.JDBCTableCatalog
import org.apache.spark.sql.functions._
import org.apache.spark.util.Utils
import org.apache.spark.sql.functions.udf
import org.apache.spark.sql.{SaveMode, SparkSession}
// h2-latest.jar needed to run this test.

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
    //Utils.classForName("org.h2.Driver")
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

     /* sparkSession.catalog.listTables.show()
    sparkSession.sql("show tables").show()
    val df7 = sparkSession.sql("select MIN(SALARY), MIN(BONUS), SUM(SALARY * BONUS) FROM h2.test.employee")
    df7.show()
    df7.explain(true)

    val df1 = sparkSession.table("h2.test.employee")
    var df9 = df1.groupBy("DEPT").agg(sum("SALARY").as("total_salary")).filter("total_salary > 500")
    df9.show()
    df9.explain(true)

    val df10 = sparkSession.sql("select NAME, SUM(SALARY+BONUS), NAME, DEPT FROM h2.test.employee" +
    " GROUP BY NAME, DEPT")
    df10.explain()
    df10.show() */
    val df = sparkSession.table("h2.test.employee")
    var tbl1 = df.select($"DEPT", $"SALARY", $"NAME")
    var tbl2 = df.select($"DEPT", $"BONUS", $"NAME")
    var query1 = tbl1.join(tbl2, tbl1("NAME") === tbl2("NAME"))
    query1.show()
    query1.explain(true)

    val connectionProperties = new Properties()
    connectionProperties.put("user", "testUser")
    connectionProperties.put("password", "testPass")
    val dfl = sparkSession.read
                         .option("driver", "org.h2.Driver")
                         .jdbc("jdbc:h2:" + tempDir.getCanonicalPath, "test.employee", connectionProperties)
                         //.load()
                         //.option("dbtable", "tpch." + name)
                         //.option("user", "testUser")
                         //.option("password", "testPass")
                         //
                         //.option("url", url)
    dfl.show()
    dfl.explain(true)
    /* val df = sparkSession.table("h2.test.employee")
    var query1 = df.select($"DEPT", $"SALARY".as("value"))
                   .groupBy($"DEPT")
                   .agg(sum($"value").as("total"))
                   .filter($"total" > 1000)
    query1.explain();
    query1.show()
    val decrease = udf { (x: Double, y: Double) => x - y}
    var query2 = df.select($"DEPT", decrease($"SALARY", $"BONUS").as("value"), $"SALARY", $"BONUS")
                  .groupBy($"DEPT")
                  .agg(sum($"value"), sum($"SALARY"), sum($"BONUS"))
    query2.show()
    query.explain("extended")*/
    /*
    query = df.select($"DEPT", $"SALARY".as("value"))
                  .groupBy($"DEPT")
                  .agg(sum($"value"))
    query.show() 
    query.explain("extended")
    
    val df = sparkSession.sql("select BONUS, SUM(SALARY+BONUS), SALARY FROM h2.test.employee" +
    " GROUP BY SALARY, BONUS")
    df.show()
    
    val df7 = sparkSession.sql("select MIN(SALARY), MIN(BONUS), SUM(SALARY * BONUS) FROM h2.test.employee")
    df7.show()
    df7.explain(true)
    val df8 = sparkSession.sql("select DEPT, SUM(BONUS * SALARY), MIN(SALARY), DEPT, MIN(BONUS), SUM(SALARY * BONUS), DEPT FROM h2.test.employee GROUP BY DEPT")
    df8.show()
    df8.explain(true)
  
    val df = sparkSession.table("h2.test.people")
    var query = df.filter($"id" > 1)
    
    df.show()
    query.explain("extended")
    query.show() 
    val df0 = sparkSession.sql("select SUM(SALARY) FROM h2.test.employee")
    df0.explain("extended")
    df0.show()
    val df1 = sparkSession.table("h2.test.employee")
    var df1a = df1.groupBy("DEPT").agg(sum("SALARY"))
    df1a.show()
    df1a.explain(true)
    val df2 = sparkSession.sql("select MAX(SALARY), MIN(BONUS) FROM h2.test.employee" +
         " group by DEPT")
    df2.explain(true)
    df2.show()
    val df3 = sparkSession.sql("select DEPT, MIN(BONUS), MAX(SALARY) FROM h2.test.employee" +
         " group by DEPT")
    df3.explain(true)
    df3.show()
         
    val df4 = sparkSession.sql("select MAX(SALARY), MIN(BONUS), DEPT FROM h2.test.employee where dept > 0" +
      " group by DEPT")
    df4.explain(true)
    df4.show()
    val df5 = sparkSession.sql("select MAX(SALARY), DEPT, MIN(BONUS), MIN(SALARY) FROM h2.test.employee where dept > 0" +
      " group by DEPT")
    df5.explain(true)
    df5.show()

    val df2 = sparkSession.sql("select MAX(ID), MIN(ID) FROM h2.test.people where id > 0")
    df2.explain(true)
    df2.show()
    // checkAnswer(df2, Seq(Row(2, 1)))

    val df3 = sparkSession.sql("select AVG(ID) FROM h2.test.people where id > 0")
    df3.explain(true)
    df3.show()
    // checkAnswer(df3, Seq(Row(1.0)))

    val df4 = sparkSession.sql("select MAX(SALARY) + 1 FROM h2.test.employee")
    df4.explain(true)
    df4.show()
    // checkAnswer(df4, Seq(Row(12001))) 

    val df2 = sparkSession.sql("select MIN(SALARY) * MIN(BONUS) FROM h2.test.employee")
    df2.explain(true)
    df2.show()
    val df6 = sparkSession.sql("select MIN(SALARY) FROM h2.test.employee group by DEPT")
    
    df6.explain(true)
    df6.show()*/
    //val df5 = sparkSession.sql("select COUNT(*) FROM h2.test.employee")
    //df5.explain(true)
    //df5.show()
    // checkAnswer(df5, Seq(Row(4)))
    println("Done")
  }
}