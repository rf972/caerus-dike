#!/bin/bash

# We assume that root is above
SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT="$SOURCE/.."

#$ROOT/./run_mc.sh custom \
#    --query "SELECT s.Location, s.PopTotal, s.PopDensity, s.Time  FROM s3object AS s WHERE s.Location LIKE '%United States of America (and dependencies)%' AND s.Time='2020' " \
#    myminio/sql-test/TotalPopulation.csv

$ROOT/run_mc.sh custom  --query "MD5"  myminio/sql-test/TotalPopulation.csv
#$ROOT/run_mc.sh custom  --query "SELECT COUNT(*) FROM s3object"  myminio/sql-test/TotalPopulation.csv
#$ROOT/run_mc.sh custom  --query "SELECT COUNT1( s.Location) FROM s3object AS s"  myminio/sql-test/TotalPopulation.csv
