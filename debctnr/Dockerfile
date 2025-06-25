FROM debian:latest

RUN apt-get update -y && \
    apt-get install -y samba acl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/nas/
RUN mkdir -p /app/config/

WORKDIR /app/

EXPOSE 139 445

CMD ["bash", "-c", "/usr/sbin/nmbd --foreground & /usr/sbin/smbd --foreground & wait -n"]
