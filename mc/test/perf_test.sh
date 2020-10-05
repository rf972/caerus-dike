#!/bin/bash

# This test expected to be run inside mc_run docker

rm -f /build/test/dikeSQL.txt
rm -f /build/test/minio.txt

rm -f /build/test/dikeSQL_5m.txt
rm -f /build/test/minio_5m.txt


if [ "$1" = "custom" ]; then
    for ((n=0;n<5;n++))
    do
    /usr/bin/time -f %e -a -o /build/test/dikeSQL.txt \
        /build/go/bin/mc -C /build/config custom \
        --query \
        "SELECT s.Location, s.PopTotal, s.PopDensity, s.Time  FROM s3object AS s WHERE s.Location LIKE '%United States of America (and dependencies)%' AND s.Time='2020' " \
        myminio/sql-test/TotalPopulation.csv
    done
fi

for ((n=0;n<5;n++))
do
/usr/bin/time -f %e -a -o /build/test/minio.txt \
    /build/go/bin/mc -C /build/config sql \
    --csv-input "rd=\n,fh=USE,fd=," \
    --query "SELECT s.Location, s.PopTotal, s.PopDensity, s.Time  FROM s3object AS s WHERE s.Location LIKE '%United States of America (and dependencies)%' AND s.Time='2020' " \
    myminio/sql-test/TotalPopulation.csv
done

if [ "$1" = "custom" ]; then
    for ((n=0;n<5;n++))
    do
    /usr/bin/time -f %e -a -o /build/test/dikeSQL_5m.txt \
        /build/go/bin/mc -C /build/config custom \
        --query "SELECT s.Country, s.'Item Type', s.'Unit Price', s.'Total Profit' FROM s3object AS s WHERE cast(s.'Total Profit' as int) > 1738000 AND cast(s.'Order ID' as int) = 798693454;" \
        myminio/sql-test/5m-Sales-Records.csv
    done
fi

for ((n=0;n<5;n++))
do
/usr/bin/time -f %e -a -o /build/test/minio_5m.txt \
    /build/go/bin/mc -C /build/config sql \
    --csv-input "rd=\r,fh=USE,fd=," \
    --query 'SELECT s.Country, s."Item Type", s."Unit Price", s."Total Profit" FROM s3object AS s WHERE  cast(s."Total Profit" as int) > 1738000 AND cast(s."Order ID" as int) = 798693454  ' \
    myminio/sql-test/5m-Sales-Records.csv    
done
