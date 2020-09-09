setup
=====

```bash
git clone https://github.com/peterpuhov-github/dike.git
git submodule init
git submodule update --recursive
docker network create dike-net
```

minio
=============
```bash
cd dike/minio/docker
./build_dockers.sh
cd ../
./build_server.sh
./run_server.sh
```
spark
=============
```bash
cd dike/spark
./build.sh

./start_spark.sh

./stop_spark
```

MinIO Client
=============
```bash
cd dike/mc/docker
./build_dockers.sh
cd ../
./build_mc.sh

./run_mc.sh config host add myminio http://minioserver:9000 admin admin123
./run_mc.sh mb myminio/spark-test
./run_mc.sh ls myminio

# Http requests can be traced in separate terminal with:
./run_mc_trace.sh admin trace -v -a myminio

```


Tests of Spark with minio and spark-select
==========================================
```
cd minio
./run_server.sh
```
In another window:
```
cd spark
./start_spark.sh

cd ../mc
./run_mc.sh config host add myminio http://minioserver:9000 admin admin123
./run_mc.sh mb myminio/spark-test
cp ../spark/examples/s3_data.csv ./build
./run_mc.sh cp build/s3_data.csv myminio/spark-test/s3_data.csv
./run_mc.sh ls myminio/spark-test

docker exec -it sparkmaster spark-submit --conf "spark.jars.ivy=/build/ivy" --packages com.amazonaws:aws-java-sdk:1.11.853,org.apache.hadoop:hadoop-aws:3.2.0,io.minio:spark-select_2.11:2.1 /examples/s3.py minioserver

docker exec -it sparkmaster spark-submit --conf "spark.jars.ivy=/build/ivy" --packages com.amazonaws:aws-java-sdk:1.11.853,org.apache.hadoop:hadoop-aws:3.2.0,org.apache.commons:commons-csv:1.8 --jars /spark-select/spark-select/target/scala-2.12/spark-select_2.12-2.1.jar /examples/s3-select.py minioserver
```