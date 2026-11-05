#!/data/data/com.termux/files/usr/bin/bash
set -uo pipefail

DIR="/data/data/com.termux/files/home/discord-bot"
TMUX="/data/data/com.termux/files/usr/bin/tmux"
SESION="discord-bot"
LOG="$DIR/boot.log"

termux-wake-lock 2>/dev/null || true

printf '[%s] boot: inicio\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"

if "$TMUX" has-session -t "$SESION" 2>/dev/null; then
    printf '[%s] boot: sesión ya existe, no se hace nada\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"
    exit 0
fi

cd "$DIR" || exit 1
"$TMUX" new-session -d -s "$SESION" "$DIR/run.sh"
printf '[%s] boot: sesión lanzada\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"
