#!/bin/sh
set -e

DATADIR="/var/lib/mysql"

DB_PASSWORD="$(cat /run/secrets/db_password)"
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

if [ -d "$DATADIR/mysql" ]; then
    echo "[mariadb] existing database found, skipping initialisation"
else
    echo "[mariadb] initialising database in $DATADIR"
    mariadb-install-db \
        --user=mysql \
        --datadir="$DATADIR" \
        --skip-test-db \
        --auth-root-authentication-method=normal >/dev/null

    echo "[mariadb] creating '${MYSQL_DATABASE}' and user '${MYSQL_USER}'"
    if ! mariadbd --user=mysql --datadir="$DATADIR" --bootstrap >/dev/null <<-SQL
		FLUSH PRIVILEGES;
		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
		DROP USER IF EXISTS ''@'localhost';
		DELETE FROM mysql.global_priv WHERE User='root' AND Host <> 'localhost';
		FLUSH PRIVILEGES;
	SQL
    then
        echo "[mariadb] initialisation failed, cleaning $DATADIR" >&2
        rm -rf "${DATADIR:?}"/*
        exit 1
    fi
    echo "[mariadb] initialisation done"
fi

# exec => mariadbd replaces the shell and becomes PID 1.
exec "$@"
