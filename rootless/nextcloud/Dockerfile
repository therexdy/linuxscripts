FROM nextcloud:latest

COPY tls/cert.pem /etc/ssl/certs/cert.pem
COPY tls/key.pem /etc/ssl/private/key.pem

RUN apt-get update && apt-get install -y ssl-cert

COPY enable-ssl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/enable-ssl.sh

ENTRYPOINT ["/usr/local/bin/enable-ssl.sh"]

