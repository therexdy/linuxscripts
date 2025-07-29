FROM debian:latest

RUN apt-get update -y && \
    apt-get install -y samba acl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/nas/
RUN mkdir -p /app/

WORKDIR /app/

EXPOSE 139 445

CMD ["bash", "./start.sh"]
