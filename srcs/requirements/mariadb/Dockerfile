FROM alpine:3.23

RUN apk add --no-cache \
        mariadb \
        mariadb-client

COPY --chmod=644 conf/zz-inception.cnf /etc/my.cnf.d/zz-inception.cnf
COPY --chmod=755 tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN mkdir -p /run/mysqld /var/lib/mysql \
    && chown -R mysql:mysql /run/mysqld /var/lib/mysql

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["mariadbd", "--user=mysql", "--console"]
