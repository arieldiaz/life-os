#!/usr/bin/env bash
# Ingest: normalize new recordings from capture locations into the spool.
# Runs every 2 min via launchd. Only touches A/V files that have been
# stable for >1 minute (so in-progress recordings are left alone).
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/stream-paths.env"

EXT_PATTERN='^(m4a|wav|mp3|aiff|aif|flac|mov|mp4|m4v|mkv|webm|ogg|opus)$'

for dir in "${CAPTURE_DIRS[@]}"; do
  [ -d "$dir" ] || continue
  find "$dir" -maxdepth 2 -type f -mmin +1 ! -name ".*" -print0 |
  while IFS= read -r -d '' f; do
    base="$(basename "$f")"
    ext="$(printf '%s' "${base##*.}" | tr '[:upper:]' '[:lower:]')"
    [[ "$ext" =~ $EXT_PATTERN ]] || continue

    day_dir="$(stat -f '%Sm' -t '%Y/%m/%d' "$f")"
    hm="$(stat -f '%Sm' -t '%H%M' "$f")"
    slug="$(printf '%s' "${base%.*}" | tr '[:upper:]' '[:lower:]' \
            | tr -cs 'a-z0-9' '-' | sed 's/^-*//;s/-*$//' | cut -c1-40)"
    [ -n "$slug" ] || slug="capture"

    dest_dir="$STREAM_LOCAL/$day_dir"
    mkdir -p "$dest_dir"
    dest="$dest_dir/$hm-$slug.$ext"
    n=1
    while [ -e "$dest" ]; do dest="$dest_dir/$hm-$slug-$n.$ext"; n=$((n+1)); done

    mv "$f" "$dest"
    echo "$(date '+%F %T') ingested: $dest"
  done
done
