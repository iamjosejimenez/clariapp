FROM alpine:3.21

RUN apk add --no-cache \
      postgresql17-client \
      aws-cli \
      bash \
      tzdata \
      coreutils \
      findutils \
      gzip \
  && ln -sf /usr/share/zoneinfo/UTC /etc/localtime

COPY backup.sh /usr/local/bin/backup.sh
COPY crontab /etc/crontabs/root

RUN chmod +x /usr/local/bin/backup.sh \
  && mkdir -p /var/backups/postgres /var/log/backup \
  && touch /var/log/backup/backup.log

CMD ["crond", "-f", "-d", "8", "-L", "/var/log/backup/backup.log"]
