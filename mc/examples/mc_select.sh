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

$ROOT/run_mc.sh mb myminio/sql-test
$ROOT/run_mc.sh cp /build/data/TotalPopulation.csv myminio/sql-test/

$ROOT/run_mc.sh sql --csv-input "rd=\n,fh=USE,fd=," \
    --query "SELECT s.Location, s.PopTotal, s.PopDensity, s.Time  FROM s3object AS s WHERE s.Location LIKE '%United States of America (and dependencies)%' AND s.Time='2020' " \
    myminio/sql-test/TotalPopulation.csv
