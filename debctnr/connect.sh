#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: Not in form connect.sh <container_name>"
    exit
fi

docker exec -it "$1" bash
