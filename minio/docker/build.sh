#!/bin/sh

cd /minio
#go install -v -ldflags "$(go run /minio/buildscripts/gen-ldflags.go)" 
go install -x -v -v -ldflags "$(go run /minio/buildscripts/gen-ldflags.go)"

