name := "Spark examples"
 
version := "1.0"
 
scalaVersion := "2.12.10"
val sparkVersion = "3.0.0"

libraryDependencies ++= Seq(
  "org.scala-lang" % "scala-library" % scalaVersion.value % "compile",
  "org.scalatest" % "scalatest_2.12" % "3.2.2",
  "org.apache.hadoop" % "hadoop-client" % "3.2.2",
)

lazy val compileScalastyle = taskKey[Unit]("compileScalastyle")

// scalastyle >= 0.9.0
compileScalastyle := scalastyle.in(Compile).toTask("").value

(compile in Compile) := ((compile in Compile) dependsOn compileScalastyle).value

// Create a default Scala style task to run with tests
lazy val testScalastyle = taskKey[Unit]("testScalastyle")

// scalastyle >= 0.9.0
testScalastyle := scalastyle.in(Test).toTask("").value

(test in Test) := ((test in Test) dependsOn testScalastyle).value