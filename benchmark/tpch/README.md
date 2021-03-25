Setup
=====

```bash
# Assuming your current directory at a top level of dike project
git submodule update benchmark/tpch/tpch-spark

./build.sh

# Create partitionned data files with schemas
./build_tbl.sh ../../data/tpch-test/

# Your data is ready !!!
```
