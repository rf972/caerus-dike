#!/bin/bash

DST_DIR=$1

if [ "$#" -ne 1 ] | [ ! -d $DST_DIR ]; then
  echo "Usage: $0 DST_DIR"
  exit 1
fi

cd tpch-spark/dbgen
for S in `seq 1 8`;
do
        ./dbgen -f -s 1 -S $S -C 8 -v
done    
cd ../../

mv tpch-spark/dbgen/*.tbl* $DST_DIR

for f in nation region supplier customer part partsupp orders lineitem
do    
    cp csv_headers/$f.csv $DST_DIR/$f.schema
done
