FROM alpine:3.23

RUN apk add --no-cache pure-ftpd

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && mkdir -p /var/www/html

# 21 = control connection, 21100-21110 = passive data connections.
EXPOSE 21 21100-21110

# -l unix  authenticate against the system accounts (/etc/passwd, /etc/shadow)
# -E       reject anonymous logins
# -A       chroot every user into its home, i.e. the WordPress volume
# -j       create that home d irectory if it does not exist yet
# -p       passive port range, published by docker-compose
# The entrypoint appends -P <address> (the passive address to announce).
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["pure-ftpd", "-l", "unix", "-E", "-A", "-j", "-p", "21100:21110"]
