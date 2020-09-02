#!/bin/sh

cd /mc
go install -x -v -v -ldflags "$(go run /minio/buildscripts/gen-ldflags.go)"

