#!/bin/bash

gcc -g -I../sqlite/build  -fPIC -shared ../sqlite/ext/misc/csv.c -o csv.so

if [ ! -f ./sqlite3.o ]; then
    gcc -Os -I. -I../sqlite/build \
        -DSQLITE_THREADSAFE=1 -DSQLITE_ENABLE_FTS4 \
        -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 \
        -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_EXPLAIN_COMMENTS \
        -DHAVE_USLEEP \
        -fmax-errors=1 \
        -c ../sqlite/build/sqlite3.c -o sqlite3.o
fi

gcc -Os -I. -I../sqlite/build \
    -DSQLITE_THREADSAFE=1 -DSQLITE_ENABLE_FTS4 \
    -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 \
    -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_EXPLAIN_COMMENTS \
    -DHAVE_USLEEP \
    -fmax-errors=1 \
    dikeSQL.cpp sqlite3.o \
    -lpthread -lm -ldl -lstdc++ -o dikeSQL

# -DSQLITE_CORE 

