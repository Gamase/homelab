#!/bin/bash
set -u

LOG="$HOME/respaldo-buzon.log"
HOY="$(date +%F)"
. "$HOME/.config/homelab/push.env"; PUSH_URL="$PUSH_RESPALDO_BUZON"

log() { echo "$(date '+%F %T') $*" >> "$LOG"; }

log "=== Inicio respaldo buzón ==="

if rclone sync "$HOME/compartido" gdrive:respaldo-buzon \
     --backup-dir "gdrive:respaldo-buzon-borrados/$HOY" >> "$LOG" 2>&1; then
  log "Sync OK."
else
  log "ERROR: rclone sync falló."
  exit 1
fi

rclone mkdir gdrive:respaldo-buzon-borrados >> "$LOG" 2>&1
rclone delete --min-age 30d gdrive:respaldo-buzon-borrados >> "$LOG" 2>&1
rclone rmdirs --leave-root gdrive:respaldo-buzon-borrados >> "$LOG" 2>&1

if curl -fsS --max-time 20 "$PUSH_URL" > /dev/null; then
  log "Push OK."
else
  log "ERROR: push a Kuma falló."
  exit 1
fi

log "=== Respaldo buzón OK ==="
