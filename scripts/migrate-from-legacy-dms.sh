#!/usr/bin/env bash
#
# Optional helpers when upgrading from older docker-mailserver (e.g. tvial/* v7)
# or cleaning up DMS v14 getmail state layout. Maildir under ./data and state
# under ./state are normally picked up automatically by current DMS images.
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CFG="${ROOT}/mail/config"
STATE="${ROOT}/state"

echo "uServer mailer — legacy DMS checks (dry-run by default)"
echo "Repo root: $ROOT"
echo ""

# DMS v15+: getmail state belongs under the state volume as lib-getmail/, not in the config volume.
if [[ -d "${CFG}/getmail" ]] && [[ ! -d "${STATE}/lib-getmail" ]]; then
  echo "[notice] Found mail/config/getmail/ but no state/lib-getmail/"
  echo "         DMS v15+ expects getmail state in the state volume (see docker-mailserver v15 changelog)."
  if [[ "${1:-}" == "--move-getmail-state" ]]; then
    mkdir -p "${STATE}/lib-getmail"
    echo "         Moving contents: ${CFG}/getmail -> ${STATE}/lib-getmail"
    # Move user data only; leave any *.cf you still want in config/getmail/ per upstream docs
    shopt -s dotglob nullglob
    for p in "${CFG}/getmail"/*; do
      base=$(basename "$p")
      if [[ -e "${STATE}/lib-getmail/${base}" ]]; then
        echo "         skip (exists): ${base}"
        continue
      fi
      mv "$p" "${STATE}/lib-getmail/"
    done
    shopt -u dotglob nullglob
    echo "         Done. Review mail/config/getmail/ for remaining *.cf configs; DMS expects getmail/*.cf in the config volume."
  else
    echo "         Re-run with: $0 --move-getmail-state  (after backup) to move files into state/lib-getmail/"
  fi
  echo ""
elif [[ -d "${CFG}/getmail" ]]; then
  echo "[ok] getmail config dir present; state/lib-getmail exists."
  echo ""
else
  echo "[ok] No mail/config/getmail (nothing to migrate for getmail)."
  echo ""
fi

echo "PostfixAdmin 3 -> 4: database upgrades are applied from the web UI (run /public/upgrade.php when prompted)"
echo "after the new container is up — see https://github.com/postfixadmin/postfixadmin/blob/master/INSTALL.TXT"
echo ""
echo "docker-mailserver image is now ghcr.io/docker-mailserver/docker-mailserver (see README)."
