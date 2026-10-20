#!/bin/sh
set -e

WP_PATH="/var/www/html"
WP="su-exec www-data wp --path=${WP_PATH}"

# Secrets, never environment variables, for anything confidential.
DB_PASSWORD="$(cat /run/secrets/db_password)"
. /run/secrets/credentials

mkdir -p "$WP_PATH"
chown -R www-data:www-data "$WP_PATH"

# Bounded readiness check: gives mariadb up to 60s, then gives up.
# This loop always terminates - it is not a `while true` keep-alive.
echo "[wordpress] waiting for ${DB_HOST} to accept connections"
i=0
while [ "$i" -lt 60 ]; do
    if mariadb-admin ping \
        --host="$DB_HOST" \
        --user="$MYSQL_USER" \
        --password="$DB_PASSWORD" \
        --silent >/dev/null 2>&1; then
        break
    fi
    i=$((i + 1))
    sleep 1
done
if [ "$i" -eq 60 ]; then
    echo "[wordpress] database unreachable after 60s, aborting" >&2
    exit 1
fi

if [ -f "$WP_PATH/wp-config.php" ]; then
    echo "[wordpress] existing installation found, skipping setup"
else
    echo "[wordpress] downloading WordPress core"
    $WP core download

    echo "[wordpress] writing wp-config.php"
    $WP config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="${DB_HOST}:3306" \
        --skip-check

    echo "[wordpress] installing site at https://${DOMAIN_NAME}"
    $WP core install \
        --url="https://${DOMAIN_NAME}" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email

    echo "[wordpress] creating second user '${WP_USER}'"
    $WP user create "$WP_USER" "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$WP_USER_PASSWORD"

    echo "[wordpress] setup done"
fi

chown -R www-data:www-data "$WP_PATH"

# exec => php-fpm replaces the shell and becomes PID 1.
exec "$@"
