#!/bin/bash

cd spark
./clean.sh
cd ..

cd pushdown-datasource
./clean.sh
cd ..

cd benchmark/tpch
./clean.sh
cd ../../

echo "Clean Done"