#!/bin/sh

cd /mc
go install -x -v -v -ldflags "$(go run /mc/buildscripts/gen-ldflags.go)"

