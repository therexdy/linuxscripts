#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: Not in form start.sh <container_name>"
    exit
fi

docker start "$1"
