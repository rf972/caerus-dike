Setup
=====

```bash
# Assuming your current directory at a top level of dike project
git submodule update mc/mc mc/minio-go minio/minio benchmark/tpch/tpch-spark

# You may want to rebouild mc and minio_server :)

cd benchmark/tpch/tpch-spark/dbgen
make

cd ../../

# Create partitionned data files with schemas
./build_tbl.sh ../../minio/data/tpch-test/

# Your data is ready !!!
```

Legacy setup
============

```bash
# You may want to rebouild mc and minio_server :)

cd benchmark/tpch/tpch-spark/dbgen
make

# Build tpch data tables (it can take a few minutes)
./dbgen -s 1

# In separate terminal run minio server
cd minio
./run_server.sh

# in separate terminal run spark
# note that you should have previously run build_all.sh at the top level or
# build.sh from /spark
cd spark
./start_spark.sh

# In the same window, hit <enter> and then
# run these commands.  

cd benchmark/tpch/
./build_tpch.sh

# This copies data down to ../../mc/build/data/
./run_tpch_init.sh

# In separate terminal run mc based tpch init and test
cd mc

# init needs to be run only once :)
./examples/mc_tpch_init.sh

# Verify  that everything is set up properly
./examples/mc_tpch_test.sh 

# Output should be similar to this:
nation.csv records:
25
region.csv records:
5
supplier.csv records:
9999
customer.csv records:
149999
part.csv records:
200000
partsupp.csv records:
800000
orders.csv records:
1500000
lineitem.csv records:
6001215

# Run a single test (test 1) with the .tbl format
./run_tpch.sh --start 1 --test tbl

# Run a single test (test 1) with the .csv format (V2 data source)
./run_tpch.sh --start 1 --test csv
```

