#!/bin/bash

DATA_DIR=$1

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 DATA_DIR"
  exit 1
fi

if [ ! -d $DATA_DIR ]; then
  echo "Usage: $0 DATA_DIR"
  echo "Hint: you might need to create the data destination"
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
make
SIZE=100
./dbgen -f -s $SIZE -v -T n
./dbgen -f -s $SIZE -v -T r
./dbgen -f -s $SIZE -v -T s
LINEITEMS=610
for S in `seq 1 $LINEITEMS`; do ./dbgen -f -s $SIZE -S $S -C $LINEITEMS -T L -v ; done
ORDERS=136
for S in `seq 1 $ORDERS`; do ./dbgen -f -s $SIZE -S $S -C $ORDERS -v -T O; done
CUSTOMERS=19
for S in `seq 1 $CUSTOMERS`; do ./dbgen -f -s $SIZE -S $S -C $CUSTOMERS -v -T c; done
PARTSUPP=94
for S in `seq 1 $PARTSUPP`; do ./dbgen -f -s $SIZE -S $S -C $PARTSUPP -v -T S; done
PART=19
for S in `seq 1 $PART`; do ./dbgen -f -s $SIZE -S $S -C $PART -v -T P; done
popd

create_bucket $DATA_DIR/tpch-test-part

#pushd tpch-spark/dbgen
#./dbgen -f -s 1 -v
#popd

#create_bucket $DATA_DIR/tpch-test

