#! /bin/bash

pushd spark
./stop.sh
popd

pushd dikeHDFS
./stop_server.sh 
popd

printf "\nAll containers stopped successfully\n"
