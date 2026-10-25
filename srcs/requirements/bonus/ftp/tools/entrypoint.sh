#!/bin/sh
set -e

: "${FTP_USER:=ftpuser}"
: "${FTP_PASV_ADDRESS:=127.0.0.1}"

FTP_PASSWORD="$(cat /run/secrets/ftp_password)"

# uid/gid 82 is www-data in the wordpress container
if ! id "$FTP_USER" >/dev/null 2>&1; then
    echo "[ftp] creating user ${FTP_USER}"
    adduser -D -H -h /var/www/html -u 82 -G www-data -s /bin/sh "$FTP_USER"
fi

echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd >/dev/null
echo "[ftp] serving /var/www/html as ${FTP_USER}, passive address ${FTP_PASV_ADDRESS}"

# The address clients are told to open passive data connections to.
set -- "$@" -P "$FTP_PASV_ADDRESS"

# exec => pure-ftpd replaces the shell and becomes PID 1.
exec "$@"
