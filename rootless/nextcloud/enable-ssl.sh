#!/bin/bash
a2enmod ssl
a2ensite default-ssl
sed -i 's|SSLCertificateFile.*|SSLCertificateFile /etc/ssl/certs/cert.pem|' /etc/apache2/sites-available/default-ssl.conf
sed -i 's|SSLCertificateKeyFile.*|SSLCertificateKeyFile /etc/ssl/private/key.pem|' /etc/apache2/sites-available/default-ssl.conf

exec /entrypoint.sh apache2-foreground
