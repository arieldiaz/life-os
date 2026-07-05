#!/usr/bin/env bash
# Backup (runs ON THE MINI): canonical stream → QNAP NAS, nightly.
# Deliberately NO --delete: the stream is append-only, so nothing should
# ever vanish from the backup — if a source file disappears, the backup
# keeping it is a feature, not drift.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/stream-paths.env"

if [ ! -d "$NAS_BACKUP_DIR" ]; then
  echo "$(date '+%F %T') NAS not mounted at $NAS_BACKUP_DIR — SKIPPED" >&2
  exit 1
fi

rsync -a --exclude ".DS_Store" "$STREAM_CANONICAL/" "$NAS_BACKUP_DIR/"
echo "$(date '+%F %T') NAS backup complete"

# Belt and suspenders: on the QNAP side, enable scheduled snapshots on this
# share (ransomware/fat-finger protection) and consider a periodic encrypted
# export offsite. The NAS protects against disk death, not against everything.
