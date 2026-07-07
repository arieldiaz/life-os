#!/usr/bin/env bash
# Nightly Infisical backup: pg_dump from the db container + a copy of the
# bootstrap .env (ENCRYPTION_KEY). Keeps 14 days.
#
# ############################################################################
# #  WITHOUT infra/secrets/.env (the ENCRYPTION_KEY) THESE DUMPS ARE         #
# #  UNRECOVERABLE. The key is copied alongside every dump, and an           #
# #  OFF-MACHINE copy (password manager / encrypted drive) is mandatory.     #
# ############################################################################
set -euo pipefail

# Resolves the repo from this script's location — works from any clone path.
ENV_FILE="$(cd "$(dirname "$0")/.." && pwd)/.env"
BACKUP_DIR="$HOME/backups/infisical"
STAMP="$(date +%F)"
KEEP_DAYS=14

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

if [ ! -f "$ENV_FILE" ]; then
  echo "backup-infisical: FATAL — $ENV_FILE missing. Dumps without the ENCRYPTION_KEY are WORTHLESS. Aborting." >&2
  exit 1
fi

# Read PG creds from the gitignored .env (values never echoed).
POSTGRES_USER="$(grep '^POSTGRES_USER=' "$ENV_FILE" | cut -d= -f2-)"
POSTGRES_DB="$(grep '^POSTGRES_DB=' "$ENV_FILE" | cut -d= -f2-)"

DUMP="$BACKUP_DIR/infisical-$STAMP.sql.gz"
docker exec infisical-db pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$DUMP"

if [ ! -s "$DUMP" ]; then
  echo "backup-infisical: FATAL — dump $DUMP is empty." >&2
  exit 1
fi

# Keep the encryption key next to the dumps (mode 600). This makes the backup
# dir itself sensitive — it must never leave machines you control.
install -m 600 "$ENV_FILE" "$BACKUP_DIR/bootstrap.env"

find "$BACKUP_DIR" -name 'infisical-*.sql.gz' -mtime +"$KEEP_DAYS" -delete

COUNT=$(find "$BACKUP_DIR" -name 'infisical-*.sql.gz' | wc -l | tr -d ' ')
SIZE=$(du -h "$DUMP" | cut -f1)
echo "backup-infisical: OK $STAMP — dump $SIZE, $COUNT dumps retained, ENCRYPTION_KEY copy present."
echo "backup-infisical: REMINDER — an off-machine copy of bootstrap.env is what makes this a real backup."
