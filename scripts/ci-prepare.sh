#!/usr/bin/env bash
# Generate env files and self-signed TLS material for ci/compose.yaml (local or GitHub Actions).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

mkdir -p ci/data/mail ci/data/state ci/data/logs ci/certs mail/config/ssl

# FILE provisioner: DMS refuses to start Dovecot with zero accounts (container then stops).
if [[ ! -s mail/config/postfix-accounts.cf ]]; then
  # Password is only for CI/local integration (see README § CI). Hash: openssl passwd -6 'ci-mail-test-password'
  printf '%s\n' '# CI/local integration — disposable mailbox (not for production).' \
    'ci@ci.local|{SHA512-CRYPT}$6$t0Y6F8262gXO2rVZ$xqvsZ0FyBPL2fuBed2EGxUa2X/svLrxE.UQzaJMG471Q8cdongTC5JmYGWUdtFLyuTtwfVC1pTU/aVajIPUBZ.' \
    > mail/config/postfix-accounts.cf
fi

# DMS (SSL_TYPE=self-signed): expects <fqdn>-key.pem, <fqdn>-cert.pem, and demoCA/cacert.pem under mail/config/ssl/
# (see /usr/local/bin/helpers/ssl.sh in the image). FQDN matches compose hostname / OVERRIDE_HOSTNAME.
DMS_FQDN="${DMS_FQDN:-mail.ci.local}"
export DMS_FQDN
mkdir -p mail/config/ssl/demoCA

if [[ ! -f "mail/config/ssl/${DMS_FQDN}-key.pem" || ! -f "mail/config/ssl/${DMS_FQDN}-cert.pem" ]]; then
  openssl req -x509 -nodes -days 2 -newkey rsa:2048 \
    -keyout "mail/config/ssl/${DMS_FQDN}-key.pem" \
    -out "mail/config/ssl/${DMS_FQDN}-cert.pem" \
    -subj "/CN=${DMS_FQDN}" \
    2>/dev/null
fi

# Postfix must trust a CA file; for a single self-signed leaf, reuse the same PEM.
if [[ ! -f mail/config/ssl/demoCA/cacert.pem ]]; then
  cp "mail/config/ssl/${DMS_FQDN}-cert.pem" mail/config/ssl/demoCA/cacert.pem
fi

if [[ ! -f ci/certs/default.pem || ! -f ci/certs/default.key ]]; then
  cp "mail/config/ssl/${DMS_FQDN}-cert.pem" ci/certs/default.pem
  cp "mail/config/ssl/${DMS_FQDN}-key.pem" ci/certs/default.key
fi

cat > ci/mail.env <<'EOF'
OVERRIDE_HOSTNAME=mail.ci.local
DOMAINNAME=ci.local
POSTMASTER_ADDRESS=postmaster@ci.local
ACCOUNT_PROVISIONER=FILE
LOG_LEVEL=info
ONE_DIR=1
PERMIT_DOCKER=connected-networks
TZ=UTC
SSL_TYPE=self-signed
TLS_LEVEL=modern
SPOOF_PROTECTION=0
ENABLE_FAIL2BAN=0
ENABLE_CLAMAV=0
ENABLE_RSPAMD=0
ENABLE_AMAVIS=0
ENABLE_OPENDKIM=0
ENABLE_OPENDMARC=0
ENABLE_UPDATE_CHECK=0
EOF

cat > ci/webmail.env <<'EOF'
ROUNDCUBEMAIL_DEFAULT_HOST=userver-mail
ROUNDCUBEMAIL_DEFAULT_PORT=143
ROUNDCUBEMAIL_SMTP_SERVER=userver-mail
ROUNDCUBEMAIL_SMTP_PORT=587
ROUNDCUBEMAIL_DB_TYPE=sqlite
ROUNDCUBEMAIL_PLUGINS=archive,zipdownload
ROUNDCUBEMAIL_SKIN=elastic
TLS_PEER_NAME=mail.ci.local
TLS_CERT_PEM_FILE=/certs/default.pem
TLS_CERT_KEY_FILE=/certs/default.key
APACHE_CERT_PEM_FILE=/certs/default.pem
APACHE_CERT_KEY_FILE=/certs/default.key
EOF

cat > ci/backup.env <<'EOF'
S3_PATH=s3://ci-placeholder-bucket/mail-backup/
ACCESS_KEY=ci-placeholder
SECRET_KEY=ci-placeholder
CRON_SCHEDULE=0 0 31 2 *
EOF

echo "ci-prepare: wrote ci/mail.env, ci/webmail.env, ci/backup.env and certs under ci/certs/"
