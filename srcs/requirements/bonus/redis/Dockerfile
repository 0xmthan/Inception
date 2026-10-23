FROM alpine:3.23

RUN apk add --no-cache redis

COPY conf/redis.conf /etc/redis.conf

RUN chown redis:redis /etc/redis.conf

EXPOSE 6379

USER redis

CMD ["redis-server", "/etc/redis.conf"]
