import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.types._

object SparkTest {
    def main(args: Array[String]) = {

        if (args.length == 0) {
            println("missing arg for s3 ip addr") 
            System.exit(1)
        }
        val s3IpAddr = args(0)
        val spark: SparkSession = SparkSession.builder()
          .master("local[1]")
          .appName("s3-select example")
          .getOrCreate()
        spark.sparkContext.setLogLevel("ERROR") // WARN INFO TRACE DEBUG
        spark.sparkContext.hadoopConfiguration.set("fs.s3a.access.key", "admin")
        spark.sparkContext.hadoopConfiguration.set("fs.s3a.secret.key", "admin123")
        spark.sparkContext.hadoopConfiguration.set("fs.s3a.endpoint", 
                                                   s"""http://$s3IpAddr:9000""")
        spark.sparkContext.hadoopConfiguration.set("fs.s3a.path.style.access", "true")
        spark.sparkContext.hadoopConfiguration.set("fs.s3a.impl", 
                                           "org.apache.hadoop.fs.s3a.S3AFileSystem")
        // filtered schema
        val schema = new StructType()
            .add("id",IntegerType,true)
            .add("name",StringType,true)
            .add("age",IntegerType,true)
            .add("city",StringType,true)

        var df = spark
            .read
            .format("minioSelectCSV")
            .schema(schema)
            .load("s3a://spark-test/s3_data.csv")

        // show all rows.
        df.show()

        // show only filtered rows.
        df.select("*").filter("age > 40").show()
        //df.select(df("name"),df("age"),df("id")).filter(df.name.like("jim")).filter("age > 40").show()
        //df.select(df("name"),df("age"),df("id")).filter(df.name.like("Jim%")).filter("age > 40").show()
        df.select(df("name"),df("age"),df("id"))
                 .filter(df.col("city").like("Miami%")).filter(df.col("name").like("Jim%")).filter("age > 40").show()
        df.select(df("name"),df("age"),df("id")).filter("age < 90").filter("age > 40").show()
        df.select(df("name"),df("age"),df("id")).filter("id < 5").filter("age > 40").show()
        var c = df.select(df("name"),df("age"),df("id")).filter("id < 5").filter("age > 40").count()
        println(s"""count is $c""")
        println("S3 Test Successful")
    }
}
