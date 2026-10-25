FROM alpine:3.23

ARG ADMINER_VERSION=6.1.2

RUN apk add --no-cache \
        php84 \
        php84-mysqli \
        php84-session

RUN apk add --no-cache --virtual .fetch-deps curl \
    && mkdir -p /var/www/adminer \
    && curl -fsSL -o /var/www/adminer/index.php \
        "https://github.com/vrana/adminer/releases/download/v${ADMINER_VERSION}/adminer-${ADMINER_VERSION}-mysql-en.php" \
    && apk del .fetch-deps \
    && adduser -D -H -s /sbin/nologin adminer \
    && chown -R adminer:adminer /var/www/adminer

EXPOSE 8081

USER adminer

CMD ["php84", "-S", "0.0.0.0:8081", "-t", "/var/www/adminer"]
