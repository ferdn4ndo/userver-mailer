#!/bin/bash

if PGPASSWORD=${POSTGRES_ROOT_PASS} psql -h "${POSTFIXADMIN_DB_HOST}" -U "${POSTGRES_ROOT_USER}" -p "${POSTFIXADMIN_DB_PORT}" -lqt | cut -d \| -f 1 | grep -qw "${POSTFIXADMIN_DB_NAME}"; then
    echo "POSTFIX ADMIN DATABASE EXISTS"
else
    echo "POSTFIX ADMIN DATABASE DOES NOT EXISTS"
    ./setup.sh
fi

apache2-foreground
