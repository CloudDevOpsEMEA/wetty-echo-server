#!/usr/bin/env bash

echo "Build clean and publish fat docker container (debug tools enabled)"
make DEBUG=true build-nc publish

echo "Build clean and publish slim docker container (debug tools disabled)"
make build-nc publish
