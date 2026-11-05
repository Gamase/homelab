#!/data/data/com.termux/files/usr/bin/bash
# Arranca crond si no está corriendo.
CROND="/data/data/com.termux/files/usr/bin/crond"
PGREP="/data/data/com.termux/files/usr/bin/pgrep"

if ! "$PGREP" -x crond >/dev/null 2>&1; then
  "$CROND"
fi
