Caerus-Dike
==============

This is a POC (Proof of Concept) of Near Data Processing (NDP), on Spark
using pushdowns.  This includes a demonstration of
pushdown on Spark of filter, project and aggregate, for both HDFS, and S3.

NDP is a technique where processing of data is pushed closer to the source of the data in an attempt to leverage locality and limit the a) data transfer and b) processing cycles needed across the set of data.

Our approach will consider use cases on Spark, and specifically focus on the use cases where Spark is processing data using SQL (Structured Query Language).  This is typical of data stored in a tabular format, and now very popular in Big Data applications and analytics.  Today, these Spark cases use SQL queries, which operate on tables (see background for more detail).  These cases require reading very large tables from storage in order to perform relational queries on the data.

Our approach will consist of pushing down portions of the SQL query to the storage itself so that the storage can perform the operations of filter, project, and aggregate and thereby limit the data transfer of these tables back to the compute node.  This limiting of data transfer also has a secondary benefit of limiting the amount of data needing to be processed on the compute node after the fetch of data is complete.

This repo has everything needed to demonstrate this capability on a single
machine using dockers.  Everything from the build to the servers, to running
the test are all utilizing dockers.

For more information, see the [Design Specification](doc/ndp_design.pdf)

Components
===========

<B>Spark</B> - The version of spark we build in this repo is a patch which contains
               the support for Aggregate pushdown in Spark.  https://github.com/apache/spark/pull/29695 <BR><BR>
<B>pushdown-datasource</B> - This is a new Spark V2 datasource, which has support for
                      pushdown of filter, project and aggregate.
                      This data source can operate against either HDFS or S3.<BR><BR>
<B>dikeCS</B> - A new S3 server, built on the <B>POCO C++ Libraries</B>, 
         but supporting S3-select API, which supports SQL Query pushdown, of filter, project and aggregate.
         This server utilizes SQLite for the query engine.<BR><BR>
<B>dikeHDFS</B> - This contains our NDP server for HDFS.  
           This server utilizes a proxy in front of HDFS.
           This also contains use of <B>SQLite</B> as the query engine.<BR><BR>
<B>TPC-H</B> - This is a fork of https://github.com/ssavvides/tpch-spark,  
        which is: TPC-H queries implemented in Spark using the DataFrames API. 
        We modified this:
        * to support our data source for S3, HDFS
        * to support a variety of data formats (csv, tbl)
        * to support a variety of testing modes such as selecting the
        pushdown used (with or without pushdown, project, filter, aggregate),
        selecting the number of partitions, or spark workers, etc.<BR><BR>

Setup
=====

```bash
git git clone https://github.com/futurewei-cloud/caerus-dike.git
cd caerus-dike
git submodule init
git submodule update --recursive --progress
# Alternatively you can update specific submodules only
# git submodule update dikeCS pushdown-datasource

docker network create dike-net

cd dikeHDFS
git submodule init
git submodule update --recursive --progress

```

Build
===========

```
./build.sh
```

Clean out artifacts
===================
In case you want to delete all the artifacts.

```
./clean.sh
```

Test of spark with HDFS NDP server (dikeHDFS)
==========================================
First, bring up the Spark and the HDFS server dockers.

```
./run_hdfs.sh
```
Then, in a separate window initialize the tpch database in HDFS.

```
cd dikeHDFS
./run_init_tpch.sh ../data
cd ..
```

Run query with no pushdown

```
cd benchmark/tpch
./run_tpch.sh -n 6 --test tblDikeHdfs
```

Run query with pushdown enabled.

```
./run_tpch.sh -n 6 --test tblDikeHdfs --s3Select
```

Test of spark with S3 server (dikeCS)
==========================================
First, bring up the Spark and the S3 server dockers.  This step also initializes the tpch database in S3.


```
./run_s3.sh
```

Then, in a separate window run the test:

Run query with no pushdown

```
cd benchmark/tpch
./run_tpch.sh -n 6 --test tblS3
```

Run query with pushdown enabled.

```
./run_tpch.sh -n 6 --test tblS3 --s3Select
```

