FROM debian:bookworm-slim

# Install Nginx, PHP-FPM, and the MySQL extension for PHP
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    php-fpm \
    php-mysqli \
    && rm -rf /var/lib/apt/lists/*

# Pin the php-fpm socket path to a fixed name so it matches nginx.conf
# regardless of which PHP version debian installs
RUN sed -i 's|^listen = .*|listen = /run/php/php-fpm.sock|' /etc/php/*/fpm/pool.d/www.conf

# Nginx site config (proxies .php requests to PHP-FPM over its unix socket)
COPY nginx.conf /etc/nginx/sites-available/default

# Application code
COPY index.php /var/www/html/index.php

# Simple startup script: launch php-fpm, then nginx in the foreground
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
