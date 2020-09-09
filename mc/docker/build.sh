#!/bin/sh

cd /minio-go
go install -x -v -v -ldflags "$(go run /minio-go/buildscripts/gen-ldflags.go)"

cd /mc
go install -x -v -v -ldflags "$(go run /mc/buildscripts/gen-ldflags.go)"

