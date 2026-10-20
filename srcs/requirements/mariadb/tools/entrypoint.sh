#!/bin/sh
set -e

DATADIR="/var/lib/mysql"
INIT_SQL="/tmp/init.sql"

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

    echo "[mariadb] preparing '${MYSQL_DATABASE}' and user '${MYSQL_USER}'"
    cat > "$INIT_SQL" <<-SQL
		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
		DROP USER IF EXISTS ''@'localhost';
		DELETE FROM mysql.global_priv WHERE User='root' AND Host <> 'localhost';
		FLUSH PRIVILEGES;
	SQL
    chown mysql:mysql "$INIT_SQL"
    chmod 600 "$INIT_SQL"

    set -- "$@" --init-file="$INIT_SQL"

    # once ping answers the file has been read and can be removed (it holds passwords).
    (
        until mariadb-admin --protocol=socket ping --silent >/dev/null 2>&1; do
            sleep 1
        done
        rm -f "$INIT_SQL"
        echo "[mariadb] removed $INIT_SQL"
    ) &
fi

# exec => mariadbd replaces the shell and becomes PID 1.
exec "$@"
