#!/bin/bash

# As per MDS tech's docker set up
if [ -f /var/www/000-default.conf ]; then
	a2dissite 000-default
fi
for file in `find "/var/www/" -maxdepth 2 -name "*.conf`; do
	ln -sf "$file" "/etc/apache2/sites-enabled/"
done;

service apache2 startup
service mysql startup
