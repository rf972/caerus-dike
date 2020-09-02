setup
=====

```bash
git clone https://github.com/peterpuhov-github/dike.git
git submodule update --recursive
```

minio
======
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
