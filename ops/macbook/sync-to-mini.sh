#!/usr/bin/env bash
# Sync: spool → mini canonical store, verified, then DELETE from MacBook.
# Runs every 5 min via launchd. If the mini is unreachable (off network),
# the spool simply accumulates until it isn't — nothing is lost.
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/stream-paths.env"

[ -d "$STREAM_LOCAL" ] || exit 0
# anything to ship?
find "$STREAM_LOCAL" -type f ! -name ".DS_Store" | head -1 | grep -q . || exit 0

# reachability check — bail quietly if the mini isn't there
ssh -o ConnectTimeout=5 -o BatchMode=yes "$MINI_USER@$MINI_HOST" true 2>/dev/null || {
  echo "$(date '+%F %T') mini unreachable; spool retained"
  exit 0
}

# --checksum: verify content, not just size/mtime.
# --remove-source-files: rsync deletes each source file ONLY after
# that file transferred successfully. This is the delete-from-MacBook step.
rsync -a --checksum --partial --remove-source-files \
  --exclude ".DS_Store" \
  "$STREAM_LOCAL/" "$MINI_USER@$MINI_HOST:$STREAM_CANONICAL/"

# sweep now-empty date directories from the spool
find "$STREAM_LOCAL" -mindepth 1 -type d -empty -delete
echo "$(date '+%F %T') sync complete; spool cleared"
