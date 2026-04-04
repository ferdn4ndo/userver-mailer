# uServer Mailer

[![E2E](https://github.com/ferdn4ndo/userver-mailer/actions/workflows/test_e2e.yml/badge.svg)](https://github.com/ferdn4ndo/userver-mailer/actions/workflows/test_e2e.yml)
[![Compose](https://github.com/ferdn4ndo/userver-mailer/actions/workflows/test_compose.yml/badge.svg)](https://github.com/ferdn4ndo/userver-mailer/actions/workflows/test_compose.yml)
[![GitLeaks](https://github.com/ferdn4ndo/userver-mailer/actions/workflows/test_code_leaks.yml/badge.svg)](https://github.com/ferdn4ndo/userver-mailer/actions/workflows/test_code_leaks.yml)
[![ShellCheck](https://github.com/ferdn4ndo/userver-mailer/actions/workflows/test_code_quality.yml/badge.svg)](https://github.com/ferdn4ndo/userver-mailer/actions/workflows/test_code_quality.yml)
[![Release](https://img.shields.io/github/v/release/ferdn4ndo/userver-mailer)](https://github.com/ferdn4ndo/userver-mailer/releases)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

A small mail stack: SMTP/IMAP (and optional POP) via [docker-mailserver](https://github.com/docker-mailserver/docker-mailserver), webmail with [Roundcube](https://roundcube.net/), optional [PostfixAdmin](https://github.com/postfixadmin/postfixadmin), and scheduled backups to S3 using `s3cmd` (pattern inspired by [istepanov/docker-backup-to-s3](https://github.com/istepanov/docker-backup-to-s3)).

Part of the [uServer](https://github.com/users/ferdn4ndo/projects/1) project.

## Versions (pinned in `docker-compose.yml`)

| Component        | Image / base                                      |
|-----------------|---------------------------------------------------|
| Mail server     | `ghcr.io/docker-mailserver/docker-mailserver:15.1.0` |
| Webmail         | `roundcube/roundcubemail:latest-apache`           |
| PostfixAdmin    | `postfixadmin:4.0.1-apache` (custom build on top) |
| Backup          | `debian:bookworm-slim` + `s3cmd`                  |

- Docker with Compose v2
- For production `docker-compose.yml`: external Docker network `nginx-proxy` (or adjust `networks` in the file)
- TLS material under `../userver-web/certs` as referenced by the default compose file

## Production stack (`docker-compose.yml`)

### Environment

1. Copy templates and edit:

   - `mail/.env.template` → `mail/.env`
   - `webmail/.env.template` → `webmail/.env`
   - `backup/.env.template` → `backup/.env` (if using backups)
   - `postfixadmin/.env.template` → `postfixadmin/.env` (if using PostfixAdmin)

2. **Compose hostname + DMS TLS:** Create a `.env` file **next to** `docker-compose.yml` with `MAIL_FQDN` set to your mail **FQDN** (same as MX / the name under `../userver-web/certs` for Let’s Encrypt, e.g. `mail.sd40.com.br`). If `MAIL_FQDN` is missing, Compose falls back to `mail.example.com` and docker-mailserver will look for certs under **that** name — which breaks `SSL_TYPE=letsencrypt` when your real cert folder uses your real domain.

   In `mail/.env`, set **`OVERRIDE_HOSTNAME`** to the **same FQDN** as `LETSENCRYPT_HOST` / `MAIL_FQDN`. DMS does not read `LETSENCRYPT_HOST`; it needs `OVERRIDE_HOSTNAME` (or a correct container hostname) to resolve `/etc/letsencrypt/live/<FQDN>/`.

3. Ensure the external Docker network `nginx-proxy` exists (or change the `networks` section in `docker-compose.yml`).

### Start

```bash
docker compose up --build
```

### Mail accounts

```bash
./mail/setup.sh email add user@domain.tld 'password'
```

With a running container named `userver-mail`:

```bash
./mail/setup.sh -c userver-mail email add user@domain.tld 'password'
```

### DKIM

```bash
./mail/setup.sh config dkim
```

Add the contents of `mail/config/opendkim/keys/<domain>/mail.txt` to DNS.

### Further CLI / env reference

- docker-mailserver: [usage](https://docker-mailserver.github.io/docker-mailserver/latest/usage/) and [environment](https://docker-mailserver.github.io/docker-mailserver/latest/config/environment/)
- Setup script help: `./mail/setup.sh` (invalid args print usage)

### Restart / update

```bash
docker compose pull
docker compose up -d --build
```

## Upgrading from older stacks

- **Mail data:** `./data` (maildir) and `./state` are generally compatible across major DMS upgrades; take a backup before upgrading.
- **Deprecated env:** `DMS_DEBUG` was removed upstream — use `LOG_LEVEL` in `mail/.env` (see `mail/.env.template`).
- **Getmail state (DMS v14 → v15):** If you used getmail and have state under `mail/config/getmail/`, see `scripts/migrate-from-legacy-dms.sh`.
- **PostfixAdmin 3 → 4:** Start the new container and complete the DB upgrade via the web installer when prompted (`upgrade.php`), or follow [PostfixAdmin INSTALL](https://github.com/postfixadmin/postfixadmin/blob/master/INSTALL.TXT).

## License

The repository’s `LICENSE` file applies to the configuration and scripts in this repo. Bundled/container images (docker-mailserver, Roundcube, PostfixAdmin, Debian, etc.) are under their respective upstream licenses.
