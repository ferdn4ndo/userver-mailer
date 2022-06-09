FROM postfixadmin:3-apache

RUN apt-get update && apt-get install -y postgresql postgresql-contrib

WORKDIR /usr/local/bin

COPY custom-entrypoint.sh /usr/local/bin/
COPY setup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/custom-entrypoint.sh
RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT ["./custom-entrypoint.sh"]

CMD ["apache2-foreground"]
