#! /bin/bash

for i in $(seq 1 22); 
do 
  echo "******** $i starting ********"
  
  ./run_tpch.sh $i nodebug 1
  STATUS=$?
  if [ $STATUS -ne 0 ] 
  then
    echo "******** Status was: $STATUS ********" 
    break
  else
    echo "******** Status was: $STATUS ********"
  fi
done
