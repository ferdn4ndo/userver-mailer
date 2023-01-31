FROM python:3.9-alpine

RUN apk update && \
    apk add bash && \
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
