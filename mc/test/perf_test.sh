#!/bin/bash

# This test expected to be run inside mc_run docker

rm -f /build/test/dikeSQL.txt
rm -f /build/test/minio.txt

for ((n=0;n<5;n++))
do
/usr/bin/time -f %e -a -o /build/test/dikeSQL.txt \
    /build/go/bin/mc -C /build/config custom \
    --query \
    "SELECT s.Location, s.PopTotal, s.PopDensity, s.Time  FROM s3object AS s WHERE s.Location LIKE '%United States of America (and dependencies)%' AND s.Time='2020' " \
    myminio/sql-test/TotalPopulation.csv
done

for ((n=0;n<5;n++))
do
/usr/bin/time -f %e -a -o /build/test/minio.txt \
    /build/go/bin/mc -C /build/config sql \
    --csv-input "rd=\n,fh=USE,fd=," \
    --query "SELECT s.Location, s.PopTotal, s.PopDensity, s.Time  FROM s3object AS s WHERE s.Location LIKE '%United States of America (and dependencies)%' AND s.Time='2020' " \
    myminio/sql-test/TotalPopulation.csv
done