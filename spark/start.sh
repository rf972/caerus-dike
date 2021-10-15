#!/bin/bash
WORKERS=1
if [ "$#" -ge 1 ] ; then
  WORKERS=$1
  echo "Workers is: $WORKERS"
fi
./docker/start-master.sh && sleep 5 && ./docker/start-worker.sh $WORKERS

sleep 5
