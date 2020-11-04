#!/bin/bash

DATA_DIR=$1

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 DATA_DIR"
  exit 1
fi

if [ ! -d $DATA_DIR ]; then
  echo "Usage: $0 DATA_DIR"
  exit 1
fi

create_bucket(){
  BUCKET=$1
  rm -rf $BUCKET
  mkdir $BUCKET
  mv tpch-spark/dbgen/*.tbl* $BUCKET
  cp schema/* $BUCKET
}

pushd tpch-spark/dbgen
for S in `seq 1 8`; do ./dbgen -f -s 1 -S $S -C 8 -v ; done
popd

create_bucket $DATA_DIR/tpch-test-part

pushd tpch-spark/dbgen
./dbgen -f -s 1 -v
popd

create_bucket $DATA_DIR/tpch-test

