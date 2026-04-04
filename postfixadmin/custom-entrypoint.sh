#!/usr/bin/env sh
# Referenced by postfixadmin/Dockerfile — run DB readiness, then hand off to CMD (apache2-foreground).
set -e
/usr/local/bin/setup.sh
exec "$@"
