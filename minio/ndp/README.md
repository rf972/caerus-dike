SQLite setup
=====

```bash
cd minio/ndp/sqlite
mkdir build
cd build

#  Run the configure script
../sqlite/configure

#  Build the "amalgamation" source file
make sqlite3.c
```
