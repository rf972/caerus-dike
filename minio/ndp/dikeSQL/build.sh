#!/bin/bash

#gcc -g -I../sqlite/build  -fPIC -shared ../sqlite/ext/misc/csv.c -o csv.so

gcc -g -O3 -I../sqlite/build -fPIC -DSQLITE_CORE -DSQLITE_OMIT_LOAD_EXTENSION -c ../sqlite/ext/misc/csv.c -o csv.o
ar rcs libcsv.a csv.o

gcc -g -O3 -I../sqlite/build -fPIC -DSQLITE_CORE -DSQLITE_OMIT_LOAD_EXTENSION -c tbl.c -o tbl.o
ar rcs libtbl.a tbl.o

if [ ! -d ../../build/ndp ]; then
    mkdir -p ../../build/ndp
fi

if [ ! -f ./sqlite3.o ]; then
    gcc -g -O3 -I. -I../sqlite/build \
        -DSQLITE_THREADSAFE=1 -DSQLITE_ENABLE_FTS4 \
        -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 \
        -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_EXPLAIN_COMMENTS \
        -DHAVE_USLEEP \
        -DSQLITE_CORE \
        -DSQLITE_OMIT_LOAD_EXTENSION=1 \
        -fmax-errors=1 \
        -c ../sqlite/build/sqlite3.c -o sqlite3.o
fi

gcc -O0 -g -I. -I../sqlite/build -I../httpparser/src \
    -fmax-errors=1 \
    -static -L. \
    dikeSQL.cpp sqlite3.o \
    -lpthread -lm  -lstdc++ -lcsv -ltbl -o dikeSQL

cp dikeSQL ../../build/ndp
# -DSQLITE_CORE 
#-ldl
#-DSQLITE_OMIT_LOAD_EXTENSION=1 \
