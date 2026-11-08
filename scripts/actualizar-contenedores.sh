#!/usr/bin/env bash
# Actualiza las imagenes de todos los stacks en ~/stacks y avisa a Kuma si todo salio bien.
set -u
. "$HOME/.config/homelab/push.env"; PUSH_URL="$PUSH_ACTUALIZAR"
LOG="$HOME/actualizar-contenedores.log"
errores=0

# Descargar una imagen a la vez, para no chocar con los limites de los registros
export COMPOSE_PARALLEL_LIMIT=1

pull_con_reintentos() {
  for intento in 1 2 3; do
    docker compose pull -q && return 0
    echo "Fallo la descarga (intento $intento), reintentando en 30 s..."
    sleep 30
  done
  return 1
}

echo "=== $(date '+%F %T') ===" >> "$LOG"
for compose in "$HOME"/stacks/*/compose.yaml; do
  dir=$(dirname "$compose"); nombre=$(basename "$dir")
  echo "--- $nombre" >> "$LOG"
  if ! (cd "$dir" && pull_con_reintentos && docker compose up -d) >> "$LOG" 2>&1; then
    echo "ERROR: $nombre" >> "$LOG"
    errores=$((errores + 1))
  fi
done

# Borra imagenes viejas que ya no usa ningun contenedor
docker image prune -f >> "$LOG" 2>&1

if [ "$errores" -eq 0 ]; then
  sleep 60  # por si Kuma se acaba de actualizar y sigue arrancando
  if curl -fsS --max-time 20 "$PUSH_URL" > /dev/null; then
    echo "Push a Kuma: OK" >> "$LOG"
  else
    echo "Push a Kuma: FALLO" >> "$LOG"
  fi
else
  echo "Termino con $errores error(es); no se avisa a Kuma" >> "$LOG"
fi
