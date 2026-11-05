#!/data/data/com.termux/files/usr/bin/sh
export PATH="/data/data/com.termux/files/usr/bin:/system/bin:$PATH"
PREFIX="/data/data/com.termux/files/usr"
LOG="$HOME/sshd-boot.log"

if ! "$PREFIX/bin/pgrep" -f "$PREFIX/bin/sshd" >/dev/null 2>&1; then
    printf '[%s] watchdog: sshd caído, reiniciando\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"
    "$PREFIX/bin/termux-wake-lock" >/dev/null 2>&1 || true
    "$PREFIX/bin/sshd" >> "$LOG" 2>&1
fi
