FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends s3cmd cron ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ADD s3cfg /root/.s3cfg

ADD scripts/start.sh /start.sh
RUN chmod +x /start.sh

ADD scripts/sync.sh /sync.sh
RUN chmod +x /sync.sh

ADD scripts/get.sh /get.sh
RUN chmod +x /get.sh

ENTRYPOINT ["/start.sh"]
CMD [""]
