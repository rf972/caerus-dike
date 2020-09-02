s3 Example
==============

First, put the s3_data.csv onto the minio data store:

mc config host add myminio http://<ip addr>:9000 admin admin123
mc mb myminio/spark-test
mc cp s3_data.csv myminio/spark-test/s3_data.csv

Next, run the s3.py on the master node:

docker exec -it spark_master spark-submit /examples/s3.py <ip addr of minio instance>

