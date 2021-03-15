Setup
=====

```bash
git clone https://<server here>/dike.git
git submodule init
git submodule update --recursive --progress
# Alternatively you can update specific submodules only
# git submodule update dikeCS pushdown-datasource
docker network create dike-net

cd dikeHDFS
git submodule init
git submodule update --recursive --progress

```

Build code
===========

```
./build.sh
```

Clean out artifacts
===================

```
./clean.sh
```

Test of spark with HDFS NDP server (dikeHDFS)
==========================================
First, bring up the Spark and the HDFS server dockers.  
./run_hdfs.sh

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

