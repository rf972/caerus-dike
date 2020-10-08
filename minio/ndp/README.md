SQLite setup
=====

```bash
cd minio/ndp/sqlite
mkdir build
cd build

#  Run the configure script
../configure

#  Build the "amalgamation" source file
make sqlite3.c
```
