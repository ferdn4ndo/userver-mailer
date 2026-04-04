#!/usr/bin/env sh
# Wait for PostgreSQL before Apache starts (variables come from postfixadmin/.env at runtime).
set -e
case "${POSTFIXADMIN_DB_TYPE:-}" in
    pgsql | postgres | postgresql)
        if [ -n "${POSTFIXADMIN_DB_HOST:-}" ]; then
            export PGPASSWORD="${POSTFIXADMIN_DB_PASSWORD:-}"
            i=0
            until pg_isready -h "$POSTFIXADMIN_DB_HOST" -p "${POSTFIXADMIN_DB_PORT:-5432}" -U "${POSTFIXADMIN_DB_USER:-postgres}" >/dev/null 2>&1; do
                i=$((i + 1))
                if [ "$i" -gt 90 ]; then
                    echo "postfixadmin setup: giving up waiting for PostgreSQL at ${POSTFIXADMIN_DB_HOST}" >&2
                    exit 1
                fi
                echo "postfixadmin setup: waiting for PostgreSQL (${POSTFIXADMIN_DB_HOST})..."
                sleep 2
            done
        fi
        ;;
esac
exit 0
