#!/bin/bash

SRC_DIR=$1
DST_DIR=$2

if [ "$#" -ne 2 ] | [ ! -d $SRC_DIR ] | [ ! -d $DST_DIR ]; then
  echo "Usage: $0 SRC_DIR DST_DIR"
  exit 1
fi


for f in nation region supplier customer part partsupp orders lineitem
do
    #echo "Building $f.csv table from $SRC_DIR/$f.tbl"
    cp csv_headers/$f.csv $DST_DIR/
    #cat $1/$f.tbl | sed -e 's/|/\,/g4' |  sed -e 's/|//'  >> $DST_DIR/$f.csv
    cat $SRC_DIR/$f.tbl | sed 's/.|$//g' | sed -e 's/|/\,/g'  >> $DST_DIR/$f.csv
    echo "$DST_DIR/$f.csv created succesfully"
done
