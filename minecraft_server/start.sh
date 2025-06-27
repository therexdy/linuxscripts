#!/bin/bash
exec docker start minecraft_server

docker attach minecraft_server
