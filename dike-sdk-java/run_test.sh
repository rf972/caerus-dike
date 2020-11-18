#!/bin/bash

docker run -it --rm  \
-v "$(pwd)/dike-test/s3/SelectObjectContent":/usr/src/mymaven \
-w /usr/src/mymaven \
-v "$(pwd)/build/root/.m2":/root/.m2 \
--network dike-net \
-e "CLASSPATH=/usr/src/mymaven/target/SelectObjectContent-uber.jar" \
-e "AWS_ACCESS_KEY_ID=admin" \
-e "AWS_SECRET_ACCESS_KEY=admin123" \
-e "AWS_EC2_METADATA_DISABLED" \
-e "DIKECS_SERVICE_ENDPOINT=http://172.18.0.2:9000" \
maven:3.6.3-jdk-8 java -Xmx1g org.dike.s3.SelectObjectContent 'tpch-test' 'lineitem.tbl' \
"SELECT * FROM S3Object"

#'SELECT SUM(s.l_extendedprice), * FROM S3Object AS s WHERE s.l_discount >= 0.05;'

#'SELECT SUM(s.l_extendedprice * s.l_discount), s.l_discount FROM S3Object AS s WHERE s.l_shipdate >= "1994-01-01" AND s.l_shipdate < "1995-01-01" AND s.l_discount >= 0.05 AND s.l_discount <= 0.07 AND s.l_quantity < 24.0'

#"SELECT SUM(s.l_extendedprice * s.l_discount), s.l_discount, s.l_extendedprice, s.l_quantity FROM S3Object AS s WHERE s.l_orderkey=5961478"

#5961478|112196|7219|2|36|43494.84|0.05|0.03|A|F|1993-05-14|1993-06-04|1993-05-19|TAKE BACK RETURN|MAIL|ly unusual ideas use. slyly pending|

#"SELECT * FROM S3Object"

#"SELECT * FROM S3Object LIMIT 1024000"

#'SELECT s.l_orderkey,s.l_partkey,s.l_suppkey,s.l_linenumber,s.l_quantity,s.l_extendedprice,s.l_discount,s.l_tax,s.l_returnflag,s.l_linestatus,s.l_shipdate,s.l_commitdate,s.l_receiptdate,s.l_shipinstruct,s.l_shipmode,s.l_comment FROM (SELECT * FROM S3Object LIMIT 0 OFFSET 1) s' 

#'SELECT s.l_orderkey FROM (SELECT * FROM S3Object LIMIT 2 OFFSET 1) AS s'
#'SELECT s.l_orderkey,s.l_partkey,s.l_suppkey,s.l_linenumber,s.l_quantity,s.l_extendedprice,s.l_discount,s.l_tax,s.l_returnflag,s.l_linestatus,s.l_shipdate,s.l_commitdate,s.l_receiptdate,s.l_shipinstruct,s.l_shipmode,s.l_comment FROM (SELECT * FROM S3Object LIMIT 2 OFFSET 1) AS s'

#'select s.l_orderkey,s.l_partkey,s.l_suppkey,s.l_linenumber,s.l_quantity,s.l_extendedprice,s.l_discount,s.l_tax,s.l_returnflag,s.l_linestatus,s.l_shipdate,s.l_commitdate,s.l_receiptdate,s.l_shipinstruct,s.l_shipmode,s.l_comment from S3Object s ORDER BY (SELECT NULL), OFFSET 1 ROWS, FETCH FIRST 2 ROWS ONLY'

#maven:3.6.3-jdk-8 java -Xmx1g org.dike.s3.SelectObjectContent 'tpch-test' 'lineitem.csv' 'select ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum, s.l_orderkey,s.l_partkey,s.l_suppkey,s.l_linenumber,s.l_quantity,s.l_extendedprice,s.l_discount,s.l_tax,s.l_returnflag,s.l_linestatus,s.l_shipdate,s.l_commitdate,s.l_receiptdate,s.l_shipinstruct,s.l_shipmode,s.l_comment from S3Object s LIMIT 5'

#maven:3.6.3-jdk-8 java -Xmx1g org.dike.s3.SelectObjectContent "$@"

#--add-host="dikecs:172.18.0.1" \