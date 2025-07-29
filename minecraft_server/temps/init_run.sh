#!/bin/bash
docker run --rm -it -v $(pwd):/app -w /app eclipse-temurin java -jar server.jar
