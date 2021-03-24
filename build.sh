#!/bin/bash
set -e

git submodule init
git submodule update --recursive --progress

docker network create dike-net | true

printf "\nBuilding Spark\n"
cd spark
./build.sh || (echo "*** Spark build failed with $?" ; exit 1)
cd ..
printf "\nBuilding Spark complete\n"

printf "\nBuilding dikeHDFS\n"
cd dikeHDFS
./build.sh || (echo "*** dikeHDFS build failed with $?" ; exit 1)
cd ..
printf "\nBuilding dikeHDFS complete\n"

printf "\nBuilding dikeCS\n"
cd dikeCS
./build.sh || (echo "*** dikeCS build failed with $?" ; exit 1)
cd ..
printf "\nBuilding dikeCS complete\n"

printf "\nBuilding pushdown-datasource\n"
cd pushdown-datasource
./build.sh || (echo "*** pushdown-datasource build failed with $?" ; exit 1)
cd ..
printf "\nBuilding pushdown-datasource complete\n"

printf "\nBuilding tpch\n"
cd benchmark/tpch
./build.sh || (echo "*** tpch build failed with $?" ; exit 1)
cd ../../
printf "\nBuilding tpch complete\n"

printf "\nBuild of ndp complete\n"
