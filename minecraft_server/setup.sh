#!/bin/bash
docker buildx build --load -t mcserv .
exec docker run -it --name minecraft_server -v ./server:/app -p 25565:25565 mcserv
