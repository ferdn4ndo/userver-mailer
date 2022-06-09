#!/bin/bash

echo "WARNING: THIS PROCESS WILL DESTROY ANY EXISTING POSTFIXADMIN DATABASE!"
echo "THIS IS IRREVERSIBLE!"
echo "Database destroy countdown: 5s (press Ctrl+C to cancel)"
sleep 1s
echo "Database destroy countdown: 4s (press Ctrl+C to cancel)"
sleep 1s
echo "Database destroy countdown: 3s (press Ctrl+C to cancel)"
sleep 1s
echo "Database destroy countdown: 2s (press Ctrl+C to cancel)"
sleep 1s
echo "Database destroy countdown: 1s (press Ctrl+C to cancel)"
sleep 1s

echo "Reseting DB..."

PGPASSWORD=${POSTGRES_ROOT_PASS} psql -h "${POSTFIXADMIN_DB_HOST}" -U "${POSTGRES_ROOT_USER}" -p "${POSTFIXADMIN_DB_PORT}" <<EOF
  REVOKE CONNECT ON DATABASE ${POSTFIXADMIN_DB_NAME} FROM public;

  SELECT pid, pg_terminate_backend(pid)
  FROM pg_stat_activity
  WHERE pg_stat_activity.datname = '${POSTFIXADMIN_DB_NAME}' AND pid <> pg_backend_pid();

  DROP DATABASE IF EXISTS ${POSTFIXADMIN_DB_NAME};
  CREATE DATABASE ${POSTFIXADMIN_DB_NAME};

  GRANT CONNECT ON DATABASE ${POSTFIXADMIN_DB_NAME} TO public;


  DROP OWNED BY ${POSTFIXADMIN_DB_USER};
  DROP USER IF EXISTS ${POSTFIXADMIN_DB_USER};
  CREATE USER ${POSTFIXADMIN_DB_USER} WITH ENCRYPTED PASSWORD '${POSTFIXADMIN_DB_PASSWORD}';

  REVOKE ALL PRIVILEGES ON DATABASE postgres FROM ${POSTFIXADMIN_DB_USER};
  ALTER USER ${POSTFIXADMIN_DB_USER} CREATEDB;
  GRANT ALL PRIVILEGES ON DATABASE ${POSTFIXADMIN_DB_NAME} TO ${POSTFIXADMIN_DB_USER};
\gexec
EOF

echo "SETUP COMPLETED!"
exit 0
