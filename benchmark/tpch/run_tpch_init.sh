#!/bin/bash
DATA_DIR=../../spark/build/tpch-data

if [ -d $DATA_DIR ]; then
  echo "Remove directory before starting script: $DATA_DIR"
  exit 1
fi
if [ ! -d $DATA_DIR ]; then
  mkdir $DATA_DIR
fi
cp ../../minio/data/tpch-test/*.tbl* $DATA_DIR
./run_tpch.sh --test init 
STATUS=$?
if [ $STATUS -eq 0 ];then
  echo "TPCH init Successful"
  DEST_DIR=../../minio/data/tpch-test-csv
  if [ ! -d $DEST_DIR ]; then
    mkdir $DEST_DIR
  fi
  mv $DATA_DIR/*.csv $DEST_DIR
  echo "csv files created: $DEST_DIR"
  sudo rm -rf ../../spark/build/tpch-data
else
  echo "TPCH init Failed"
fi
