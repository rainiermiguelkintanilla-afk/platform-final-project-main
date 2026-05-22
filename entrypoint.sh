#!/bin/bash
set -e

# Railway sets PORT (e.g. 8080); local Docker uses 80 via docker-compose mapping
LISTEN_PORT="${PORT:-80}"
echo "Configuring Nginx to listen on port ${LISTEN_PORT}..."
sed -i "s/listen 80 default_server;/listen ${LISTEN_PORT} default_server;/" /etc/nginx/conf.d/symfony.conf

echo "Running database migrations (if DATABASE_URL is configured)..."
php bin/console doctrine:migrations:migrate --no-interaction --env=prod --allow-no-migration || true

echo "Starting PHP-FPM..."
php-fpm -D

echo "Waiting for PHP-FPM to start..."
sleep 2

echo "Starting Nginx..."
exec nginx -g "daemon off;"