FROM alpine:3.23

RUN apk add --no-cache \
        nginx \
        openssl \
        gettext

COPY conf/nginx.conf.template /etc/nginx/nginx.conf.template
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && mkdir -p /etc/nginx/ssl /var/www/html \
    && rm -f /etc/nginx/http.d/default.conf

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
