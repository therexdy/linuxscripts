#!/bin/bash
exec docker run -it --rm --name test -v ./server:/app -p 25565:25565 mcserv
