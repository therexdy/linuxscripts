#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: Not in form create_container.sh <container_name>"
    exit
fi

docker run -it -d --name "$1" -p 139:139 -p 445:445 -v ./nas/:/app/nas/ -v ./configs/:/app/config/ rexdy_smb
