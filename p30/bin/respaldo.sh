#!/data/data/com.termux/files/usr/bin/bash
set -u

export HOME="/data/data/com.termux/files/home"
export PREFIX="/data/data/com.termux/files/usr"
export PATH="$PREFIX/bin:$PREFIX/glibc/bin:/system/bin:/system/xbin"
export TMPDIR="$PREFIX/tmp"

LOG="$HOME/respaldo.log"
STAMP="$(date +%F)"
ARCHIVE="respaldo-p30-$STAMP.tar.gz"
. "$HOME/.config/homelab/push.env"; PUSH_URL="$PUSH_RESPALDO_P30"

umask 077
WORK="$(mktemp -d "$TMPDIR/respaldo-p30.XXXXXX")" || {
  echo "No se pudo crear carpeta temporal" >&2
  exit 1
}
STAGE="$WORK/stage"
mkdir -p "$STAGE"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG"
}

fail() {
  log "ERROR: $*"
  exit 1
}

cleanup() {
  if [ -n "${WORK:-}" ] && [ -d "$WORK" ]; then
    rm -rf "$WORK"
  fi
}
trap cleanup EXIT
trap 'exit 1' INT TERM

log "=== Inicio respaldo $STAMP ==="

# Configuración del nodo.
mkdir -p "$STAGE/boot"
cp -a "$HOME/.termux/boot/." "$STAGE/boot/" >> "$LOG" 2>&1 \
  || fail "No se pudo copiar ~/.termux/boot"
if [ -f "$PREFIX/bin/despertar-pc" ]; then
  cp -a "$PREFIX/bin/despertar-pc" "$STAGE/" >> "$LOG" 2>&1 \
    || fail "No se pudo copiar despertar-pc"
else
  log "Aviso: no existe despertar-pc"
fi
cp -a "$PREFIX/etc/ssh/sshd_config" "$STAGE/sshd_config" >> "$LOG" 2>&1 \
  || fail "No se pudo copiar sshd_config"
cp -a "$HOME/.ssh/authorized_keys" "$STAGE/authorized_keys" >> "$LOG" 2>&1 \
  || fail "No se pudo copiar authorized_keys"
if crontab -l > "$STAGE/crontab.txt" 2>>"$LOG"; then
  log "crontab copiado."
else
  echo "(sin crontab o crontab -l falló)" > "$STAGE/crontab.txt"
  log "Aviso: crontab -l falló o está vacío."
fi

log "Empaquetando $ARCHIVE..."
tar -czf "$WORK/$ARCHIVE" -C "$STAGE" . >> "$LOG" 2>&1 || fail "tar falló"
[ -s "$WORK/$ARCHIVE" ] || fail "El archivo tar.gz quedó vacío"

log "Subiendo a gdrive:respaldos-p30/..."
rclone copy "$WORK/$ARCHIVE" "gdrive:respaldos-p30/" >> "$LOG" 2>&1 \
  || fail "rclone copy falló"

log "Borrando respaldos con más de 30 días..."
rclone delete --min-age 30d "gdrive:respaldos-p30/" >> "$LOG" 2>&1 \
  || fail "rclone delete falló"

log "Enviando push a Kuma..."
if curl -fsS --max-time 20 "$PUSH_URL" >/dev/null 2>>"$LOG"; then
  log "Push OK."
else
  log "ERROR: push a Kuma falló."
  exit 1
fi

log "=== Respaldo OK: $ARCHIVE ==="
exit 0
