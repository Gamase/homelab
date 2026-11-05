NODO="docker"

compartir() {
  [ $# -eq 0 ] && { echo "Uso: compartir <archivo|carpeta>..."; return 1; }
  scp -r "$@" "$NODO:~/compartido/" && echo "✓ Subido. Ver en https://archivos.familiamtz.com"
}

traer() {
  [ $# -eq 0 ] && { echo "Uso: traer <archivo>..."; return 1; }
  for f in "$@"; do scp -r "$NODO:~/compartido/$f" .; done
}

buzon() {
  ssh "$NODO" 'ls -lh ~/compartido'
}

borrar() {
  [ $# -eq 0 ] && { echo "Uso: borrar <archivo>..."; return 1; }
  printf "¿Borrar del buzón: %s? [s/N] " "$*"
  read r
  [ "$r" = "s" ] || { echo "Cancelado."; return 1; }
  for f in "$@"; do ssh "$NODO" "rm -rv ~/compartido/'$f'"; done
}

# Despertar la PC desde la VM docker (siempre encendida)
wakeup() {
  local vars=""
  [ -n "$WAKEUP_LIMITE" ] && vars+="WAKEUP_LIMITE=$WAKEUP_LIMITE "
  [ -n "$WAKEUP_INTERVALO" ] && vars+="WAKEUP_INTERVALO=$WAKEUP_INTERVALO "
  ssh -t docker "${vars}~/bin/despertar-pc"
}
