FROM alpine:3.23

RUN apk add --no-cache \
        php84 \
        php84-fpm \
        php84-mysqli \
        php84-ctype \
        php84-curl \
        php84-dom \
        php84-exif \
        php84-fileinfo \
        php84-gd \
        php84-iconv \
        php84-intl \
        php84-mbstring \
        php84-opcache \
        php84-pecl-redis \
        php84-openssl \
        php84-phar \
        php84-session \
        php84-simplexml \
        php84-tokenizer \
        php84-xml \
        php84-xmlreader \
        php84-xmlwriter \
        php84-zip \
        curl \
        mariadb-client \
        su-exec

# Alpine ships the www-data *group* (gid 82) but no matching user.
RUN adduser -u 82 -D -S -G www-data www-data

RUN curl -fsSL -o /usr/local/bin/wp \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php84/php-fpm.d/www.conf
COPY conf/client.cnf /etc/my.cnf.d/client.cnf
COPY conf/php.ini  /etc/php84/conf.d/99-inception.ini
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && mkdir -p /var/www/html /run/php-fpm \
    && chown -R www-data:www-data /var/www/html

EXPOSE 9000

# -F keeps php-fpm in the foreground as PID 1 (its own no-fork flag).
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm84", "-F"]
