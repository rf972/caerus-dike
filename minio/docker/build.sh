#!/bin/sh

cd /minio
go install -x -v -v -ldflags "$(go run /minio/buildscripts/gen-ldflags.go)"

