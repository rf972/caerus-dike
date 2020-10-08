#!/bin/bash

# We assume that root is above
SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT="$SOURCE/.."

$ROOT/run_mc.sh minio sql --csv-input "rd=\n,fh=USE,fd=," \
    --query 'select s."l_orderkey",s."l_partkey",s."l_suppkey",s."l_linenumber",s."l_quantity",s."l_extendedprice",s."l_discount",s."l_tax",s."l_returnflag",s."l_linestatus",s."l_shipdate",s."l_commitdate",s."l_receiptdate",s."l_shipinstruct",s."l_shipmode",s."l_comment" from S3Object AS s LIMIT 8, 10' \
    myminio/tpch-test/lineitem.csv


$ROOT/run_mc.sh minio sql --csv-input "rd=\n,fh=USE,fd=," \
    --query 'select s."l_orderkey",s."l_partkey",s."l_suppkey",s."l_linenumber",s."l_quantity",s."l_extendedprice",s."l_discount",s."l_tax",s."l_returnflag",s."l_linestatus",s."l_shipdate",s."l_commitdate",s."l_receiptdate",s."l_shipinstruct",s."l_shipmode",s."l_comment" from S3Object s' \
    myminio/tpch-test/lineitem.csv
