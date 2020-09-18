#!/bin/bash

# We assume that root is above
SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT="$SOURCE/.."

#$ROOT/run_mc.sh minio sql --csv-input "rd=\n,fh=USE,fd=," \
#    --query "SELECT s.Location, s.PopTotal, s.PopDensity, s.Time  FROM s3object AS s WHERE s.Location LIKE '%United States of America (and dependencies)%' AND s.Time='2020' " \
#    myminio/sql-test/TotalPopulation.csv


#Region,Country,Item Type,Sales Channel,Order Priority,Order Date,Order ID,Ship Date,Units Sold,Unit Price,Unit Cost,Total Revenue,Total Cost,Total Profit
#$ROOT/run_mc.sh minio sql --csv-input "rd=\r,fh=USE,fd=," \
#    --query "SELECT s.Country, s.'Item Type', MAX(s.'Total Profit') FROM s3object AS s WHERE s.Region LIKE 'Europe' AND s.'Unit Price'>50 " \
#    myminio/sql-test/5m-Sales-Records.csv

$ROOT/run_mc.sh minio sql --csv-input "rd=\r,fh=USE,fd=," \
    --query 'SELECT s.Country, s."Item Type", s."Unit Price", s."Total Profit" FROM s3object AS s WHERE  cast(s."Total Profit" as int) > 1738000 AND cast(s."Order ID" as int) = 798693454  ' \
    myminio/sql-test/5m-Sales-Records.csv    


#"SELECT s.Country, s.'Item Type', s.'Unit Price', s.'Total Profit' FROM s3object AS s WHERE cast(s.'Total Profit' as int) > 1738000 AND s.Country='Poland';" \    