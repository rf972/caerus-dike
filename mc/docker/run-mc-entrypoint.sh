#!/bin/sh

#export PATH=$PATH:/build/go/bin

# If command does not starts with minio
# simply run it 
if [ "${1}" != "minio" ]; 
then
    "$@"
else
    /build/go/bin/mc -C /build/config "$@"
fi




