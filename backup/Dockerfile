FROM debian:jessie

RUN apt-get update && \
    apt-get install -y python python-pip cron && \
    rm -rf /var/lib/apt/lists/*

RUN pip install s3cmd

ADD s3cfg /root/.s3cfg

ADD scripts/start.sh /start.sh
RUN chmod +x /start.sh

ADD scripts/sync.sh /sync.sh
RUN chmod +x /sync.sh

ADD scripts/get.sh /get.sh
RUN chmod +x /get.sh

ENTRYPOINT ["/start.sh"]
CMD [""]
