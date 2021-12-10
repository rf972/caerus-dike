#!/bin/bash
#
# This script copies tpc-h queries from a spark-sql-perf
# repo into this repo.
#
mkdir -p tpch-spark/src/main/resources
if [ ! -d $SPARK_SQL_PERF/src/main/resources/tpch ] ; then
  echo "please set SPARK_SQL_PERF environment variable"
else
  cp -r $SPARK_SQL_PERF/src/main/resources/tpch tpch-spark/src/main/resources
fi
