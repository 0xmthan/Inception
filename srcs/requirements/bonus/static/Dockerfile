FROM alpine:3.23

RUN apk add --no-cache nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY site/ /var/www/static/

RUN rm -f /etc/nginx/http.d/default.conf \
    && chown -R nginx:nginx /var/www/static

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
