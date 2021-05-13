#!/bin/bash

./build_spark.sh || (echo "*** Spark build failed with $?" ; exit 1)
