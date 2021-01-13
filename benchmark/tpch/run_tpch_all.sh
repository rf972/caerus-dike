#! /bin/bash

CURRENT_TIME=$(date "+%Y-%m-%d-%H-%M-%S")
RESULTS_FILE="./${CURRENT_TIME}_result.txt"
echo "results file is: $RESULTS_FILE"

script $RESULTS_FILE -c ./run_all_script.sh
