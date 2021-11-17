#!/bin/bash
TESTS=$1
DS=$2
echo "Running tests $TESTS"
set_speed() {
  ssh roc_6 "sudo tc qdisc change dev eno2 root tbf rate $1 limit 1mb burst 1mb ; sudo tc qdisc show dev eno2"
  ssh roc_6 "sudo tc qdisc change dev eno3 root tbf rate $1 limit 1mb burst 1mb ; sudo tc qdisc show dev eno3"
  sleep 1
}
if [ "$DS" == "spark" ]; then
  set_speed "128mbit"
  ./run_tpch.py --workers 4 -t $TESTS --args "-ds spark --protocol hdfs --format parquet"

  set_speed "256mbit"
  ./run_tpch.py --workers 8 -t $TESTS --args "-ds spark --protocol hdfs --format parquet"

  set_speed "384mbit"
  ./run_tpch.py --workers 12 -t $TESTS --args "-ds spark --protocol hdfs --format parquet"

  set_speed "512mbit"
  ./run_tpch.py --workers 16 -t $TESTS --args "-ds spark --protocol hdfs --format parquet"

  set_speed "640mbit"
  ./run_tpch.py --workers 20 -t $TESTS --args "-ds spark --protocol hdfs --format parquet"

  set_speed "768mbit"
  ./run_tpch.py --workers 24 -t $TESTS --args "-ds spark --protocol hdfs --format parquet"

  set_speed "896mbit"
  ./run_tpch.py --workers 28 -t $TESTS --args "-ds spark --protocol hdfs --format parquet"

  set_speed "1024mbit"
  ./run_tpch.py --workers 32 -t $TESTS --args "-ds spark --protocol hdfs --format parquet"
elif [ "$DS" == "ndp" ]; then
  #COMPRESSION="--compression ZSTD --compLevel 3"
  COMPRESSION="--compression None"
  set_speed "128mbit"
  ./run_tpch.py --workers 4 -t $TESTS --args "-ds spark --protocol hdfs --format parquet --pushRule $COMPRESSION"

  set_speed "256mbit"
  ./run_tpch.py --workers 8 -t $TESTS --args "-ds spark --protocol hdfs --format parquet --pushRule $COMPRESSION"

  set_speed "384mbit"
  ./run_tpch.py --workers 12 -t $TESTS --args "-ds spark --protocol hdfs --format parquet --pushRule $COMPRESSION"

  set_speed "512mbit"
  ./run_tpch.py --workers 16 -t $TESTS --args "-ds spark --protocol hdfs --format parquet --pushRule $COMPRESSION"

  set_speed "640mbit"
  ./run_tpch.py --workers 20 -t $TESTS --args "-ds spark --protocol hdfs --format parquet --pushRule $COMPRESSION"

  set_speed "768mbit"
  ./run_tpch.py --workers 24 -t $TESTS --args "-ds spark --protocol hdfs --format parquet --pushRule $COMPRESSION"

  set_speed "896mbit"
  ./run_tpch.py --workers 28 -t $TESTS --args "-ds spark --protocol hdfs --format parquet --pushRule $COMPRESSION"

  set_speed "1024mbit"
  ./run_tpch.py --workers 32 -t $TESTS --args "-ds spark --protocol hdfs --format parquet --pushRule $COMPRESSION"
fi
