#!/usr/bin/env bash
# Integration checks against the stack from ci/compose.yaml (non-privileged host ports).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE=${COMPOSE_FILE:-ci/compose.yaml}
COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-userver-mailer-ci}
COMPOSE=(docker compose --project-name "$COMPOSE_PROJECT_NAME" -f "$COMPOSE_FILE" --project-directory "$ROOT")

SMTP_PORT=${SMTP_PORT:-2525}
IMAP_PORT=${IMAP_PORT:-1143}
SUBMISSION_PORT=${SUBMISSION_PORT:-1587}
WEBMAIL_PORT=${WEBMAIL_PORT:-18080}

cd "$ROOT"

echo "== compose ps =="
"${COMPOSE[@]}" ps -a

echo "== SMTP (port ${SMTP_PORT}) =="
nc -z -w 5 127.0.0.1 "$SMTP_PORT"

echo "== IMAP (port ${IMAP_PORT}) =="
nc -z -w 5 127.0.0.1 "$IMAP_PORT"

echo "== Submission (port ${SUBMISSION_PORT}) =="
nc -z -w 5 127.0.0.1 "$SUBMISSION_PORT"

echo "== Webmail HTTP (port ${WEBMAIL_PORT}) =="
curl -sf --max-time 15 "http://127.0.0.1:${WEBMAIL_PORT}/" >/dev/null

echo "== All integration checks passed =="
