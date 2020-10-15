#!/bin/bash
DATA_DIR=../../spark/build/tpch-data

if [ -d $DATA_DIR ]; then
  echo "Remove directory before starting script: $DATA_DIR"
  exit 1
fi
if [ ! -d $DATA_DIR ]; then
  mkdir $DATA_DIR
fi
cp tpch-spark/dbgen/*.tbl ../../spark/build/tpch-data
./run_tpch.sh --test init 
STATUS=$?
if [ $STATUS -eq 0 ];then
  echo "TPCH init Successful"
  DEST_DIR=../../mc/build/data
  if [ ! -d $DEST_DIR ]; then
    mkdir $DEST_DIR
  fi
  cp $DATA_DIR/*.csv $DEST_DIR
  echo "Copied resulting csv files to $DEST_DIR"
else
  echo "TPCH init Failed"
fi
