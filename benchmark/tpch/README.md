setup
=====

```bash
# Assuming your current directory at a top level of dike project
git submodule update mc/mc mc/minio-go minio/minio benchmark/tpch/tpch-spark

# You may want to rebouild mc and minio_server :)

cd benchmark/tpch/tpch-spark/dbgen
make

# Build tpch data tables (it can take a few minutes)
./dbgen -s 1

# Convert to csv format
cd ../../
# You should be at benchmark/tpch directory
./build_csv.sh tpch-spark/dbgen ../../mc/build/data/

# In separate terminal run minio server
cd minio
./run_server.sh

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

```

