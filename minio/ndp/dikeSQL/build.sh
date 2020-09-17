#!/bin/bash

gcc -g -I../sqlite/build  -fPIC -shared ../sqlite/ext/misc/csv.c -o csv.so

if [ ! -d ../../build/ndp ]; then
    mkdir -p ../../build/ndp
fi

if [ ! -f ./sqlite3.o ]; then
    gcc -v -Os -I. -I../sqlite/build \
        -DSQLITE_THREADSAFE=1 -DSQLITE_ENABLE_FTS4 \
        -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 \
        -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_EXPLAIN_COMMENTS \
        -DHAVE_USLEEP \
        -fmax-errors=1 \
        -c ../sqlite/build/sqlite3.c -o sqlite3.o
fi

gcc -O0 -g -I. -I../sqlite/build -I../httpparser/src \
    -DSQLITE_THREADSAFE=1 -DSQLITE_ENABLE_FTS4 \
    -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 \
    -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_EXPLAIN_COMMENTS \
    -DHAVE_USLEEP \
    -fmax-errors=1 \
    dikeSQL.cpp sqlite3.o \
    -lpthread -lm -ldl -lstdc++ -o dikeSQL

cp dikeSQL csv.so ../../build/ndp
# -DSQLITE_CORE 

