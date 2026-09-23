#!/bin/sh
set -e
# Start PHP-FPM in the background
php-fpm8.2 -D 2>/dev/null || php-fpm -D
# Run Nginx in the foreground so the container stays alive
nginx -g "daemon off;"
