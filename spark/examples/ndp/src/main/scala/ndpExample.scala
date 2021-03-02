package com.github.ndp.tests


import java.io.InputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.lang.RuntimeException
import java.net.URI

import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;

import java.time._

import org.apache.log4j.Logger;
import org.apache.log4j.Level;
import org.apache.log4j.BasicConfigurator;

import org.apache.hadoop.conf.Configuration
import org.apache.hadoop.fs.Path
import org.apache.hadoop.fs.FileSystem
import org.apache.hadoop.fs.FSDataInputStream
import org.apache.hadoop.hdfs.web.NdpHdfsFileSystem

object ndpTests {

  // not used right now.
  def configure() : Configuration = {
    val conf = new Configuration
    val userName = System.getProperty("user.name")
    val hdfsCoreSitePath = new Path("/home/" + userName + "/config/core-client.xml")
    val hdfsHDFSSitePath = new Path("/home/" + userName + "/config/hdfs-site.xml")
    conf.addResource(hdfsCoreSitePath);
    conf.addResource(hdfsHDFSSitePath);
    conf
  }
  def getFileSystem(endpoint: String) : Any = {
    val conf = new Configuration()
    conf.set("dfs.datanode.drop.cache.behind.reads", "true")
    conf.set("dfs.client.cache.readahead", "0")
    conf.set("fs.ndphdfs.impl", classOf[org.apache.hadoop.hdfs.web.NdpHdfsFileSystem].getName)
   
    val fs = FileSystem.get(URI.create(endpoint), conf)
    fs.asInstanceOf[NdpHdfsFileSystem]
  }
    
  def ndpTest(args: Array[String]) { 
    if (args.length == 0) {
        println("missing filename") 
        System.exit(1)
    }
    val conf = configure
    val endpoint = "ndphdfs://dikehdfs"
    val fileName = args(0)

    var startTime = System.currentTimeMillis();

    var totalRecords = 0
    var totalDataSize = 0
    val fs = getFileSystem(endpoint).asInstanceOf[FileSystem]

    try {      
      val filePath = new Path(fileName)
      val ndpFs = fs.asInstanceOf[NdpHdfsFileSystem]
      val inStrm = ndpFs.open(filePath, 4096, "").asInstanceOf[FSDataInputStream]
       
      println("Scheme " + fs.getScheme());
      FileSystem.getStatistics.get(fs.getScheme()).reset();

      println("\nConnected to -- " + filePath.toString());
      startTime = System.currentTimeMillis();
      inStrm.seek(0)

      println("opened: " + fileName)
      val br = new BufferedReader(new InputStreamReader(inStrm,StandardCharsets.UTF_8))
      var record = br.readLine()
      while (record != null && record.length() > 0){
          if (totalRecords < 5) {
              println(record)
          }
          totalDataSize += record.length() + 1 // +1 to count end of line
          totalRecords += 1

          record = br.readLine() // Should be last !!!
      }
      br.close()
    } catch {
      case ex: Exception =>
        System.out.println("Error occurred: ");
        ex.printStackTrace();
        val endTime = System.currentTimeMillis();            
        println("Received %d records (%d bytes) in %.3f sec\n".format(
                totalRecords, totalDataSize, (endTime - startTime) / 1000.0))
        return;
    }
    val endTime = System.currentTimeMillis();
        
    System.out.println(fs.getScheme());
    println("BytesRead %d\n"format(FileSystem.getStatistics.get(fs.getScheme()).getBytesRead()))
    println("Received %d records (%d bytes) in %.3f sec\n".format(
            totalRecords, totalDataSize, (endTime - startTime) / 1000.0))
  }

  def main(args: Array[String]) {
    // Suppress log4j warnings
    BasicConfigurator.configure()
    Logger.getRootLogger().setLevel(Level.INFO)

    ndpTest(args)
  }
}
