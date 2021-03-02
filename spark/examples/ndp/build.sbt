name := "hdfs examples"
 
version := "1.0"
 
scalaVersion := "2.12.10"

libraryDependencies ++= Seq(
  "org.scala-lang" % "scala-library" % scalaVersion.value % "compile",
  "org.scalatest" % "scalatest_2.12" % "3.2.2",
)
