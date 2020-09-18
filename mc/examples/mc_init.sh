#!/bin/bash

# We assume that root is above
SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT="$SOURCE/.."

# Download test file
if [ ! -d $ROOT/build/data ]; then
  mkdir $ROOT/build/data
fi

if [ ! -f $ROOT/build/data/TotalPopulation.csv ]; then
    curl "https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/CSV_FILES/WPP2019_TotalPopulationBySex.csv" > $ROOT/build/data/TotalPopulation.csv
fi

if [ ! -f $ROOT/build/data/5m-Sales-Records.csv ]; then
  curl "http://eforexcel.com/wp/wp-content/uploads/2020/09/5m-Sales-Records.zip"  > $ROOT/build/data/5m-Sales-Records.zip
  unzip  $ROOT/build/data/5m-Sales-Records.zip -d  $ROOT/build/data/
  mv $ROOT/'build/data/5m Sales Records.csv' $ROOT/build/data/5m-Sales-Records.csv
fi

$ROOT/run_mc.sh minio config host add myminio http://minioserver:9000 admin admin123
$ROOT/run_mc.sh minio mb myminio/sql-test
$ROOT/run_mc.sh minio cp /build/data/TotalPopulation.csv myminio/sql-test/
$ROOT/run_mc.sh minio cp /build/data/5m-Sales-Records.csv myminio/sql-test/

