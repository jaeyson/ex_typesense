#!/bin/bash

ARCH=$(uname -m)
if [ -z "$ARCH" ]; then
  echo "Error: Unable to determine architecture"
  exit 1
fi

if [ "$ARCH" = "arm64" ]; then
  export TYPESENSE_IMAGE=${TYPESENSE_IMAGE:-"docker.io/typesense/typesense:26.0-arm64"}
else
  export TYPESENSE_IMAGE=${TYPESENSE_IMAGE:-"docker.io/typesense/typesense:26.0"}
fi

docker compose up -d && docker container logs --follow --tail 50 typesense
