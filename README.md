setup
=====

```bash
git clone https://github.com/peterpuhov-github/dike.git
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

# Make sure that minio server is running and use reported IP 172.X.X.X:9000
# for browser access.
# 
./run_mc.sh config host add myminio http://minio_server:9000 admin admin123
./run_mc.sh mb myminio/spark-test
./run_mc.sh ls myminio
```