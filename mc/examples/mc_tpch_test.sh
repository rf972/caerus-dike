#!/bin/bash

# We assume that root is above
SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT="$SOURCE/.."


for f in nation region supplier customer part partsupp order lineitem
do
    echo "$f.csv records:"
    $ROOT/run_mc.sh minio sql --csv-input "rd=\r,fh=USE,fd=," \
        --query "SELECT COUNT(*) FROM s3object" \
        myminio/tpch-test/$f.csv    

done
