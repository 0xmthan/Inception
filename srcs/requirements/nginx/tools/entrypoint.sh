#!/bin/sh
set -e

: "${DOMAIN_NAME:=localhost}"

SSL_DIR="/etc/nginx/ssl"
CRT="${SSL_DIR}/inception.crt"
KEY="${SSL_DIR}/inception.key"

mkdir -p "$SSL_DIR"

if [ ! -f "$CRT" ] || [ ! -f "$KEY" ]; then
    echo "[nginx] generating self-signed certificate for ${DOMAIN_NAME}"
    openssl req -x509 -nodes -newkey rsa:2048 -sha256 -days 365 \
        -keyout "$KEY" -out "$CRT" \
        -subj "/C=TR/L=Istanbul/O=42Istanbul/OU=42/CN=${DOMAIN_NAME}" \
        -addext "subjectAltName=DNS:${DOMAIN_NAME},DNS:www.${DOMAIN_NAME}"
    chmod 600 "$KEY"
fi

envsubst '${DOMAIN_NAME}' \
    < /etc/nginx/nginx.conf.template \
    > /etc/nginx/nginx.conf

nginx -t

if [ "$#" -eq 0 ]; then
    set -- nginx -g "daemon off;"
fi

exec "$@"
