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
./build.sh

Clean out artifacts
===================
./clean.sh

spark
=============
```bash
cd dike/spark
./build.sh

./start_spark.sh

./stop_spark
```

dikeCS
=============
```bash
cd dikeCS

cd external
./build_aws.sh
cd ..

./build.sh

./run_dikeCS.sh

```
Test of spark with HDFS (dikeHDFS)
==================================

cd dikeHDFS
./start_server.sh

# In separate window
# Make sure that your path is correct
DATA=data/
./run_init_tpch.sh ${DATA}
echo "Done building Dike all"

Test of spark with S3 server (DikeCS)
==========================================
```
```

