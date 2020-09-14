name := "Spark-select examples"
 
version := "1.0"
 
scalaVersion := "2.12.10"
val sparkVersion = "3.1.0"
val sparkVersionMinor = "SNAPSHOT"

libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % sparkVersion % sparkVersionMinor,
  "org.apache.spark" %% "spark-sql" % sparkVersion % sparkVersionMinor,
  "org.scala-lang" % "scala-library" % scalaVersion.value % "compile"

)
