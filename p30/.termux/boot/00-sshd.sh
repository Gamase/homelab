#!/data/data/com.termux/files/usr/bin/sh
export PATH="/data/data/com.termux/files/usr/bin:/system/bin:$PATH"
export HOME="${HOME:-/data/data/com.termux/files/home}"
PREFIX="/data/data/com.termux/files/usr"
LOG="$HOME/sshd-boot.log"

log() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG"
}

sshd_running() {
    "$PREFIX/bin/pgrep" -f "$PREFIX/bin/sshd" >/dev/null 2>&1
}

log "boot: iniciando sshd"

if sshd_running; then
    log "sshd ya estaba corriendo"
    exit 0
fi

"$PREFIX/bin/termux-wake-lock" >/dev/null 2>&1 || log "aviso: termux-wake-lock falló"

intento=1
while [ "$intento" -le 5 ]; do
    "$PREFIX/bin/sshd" >> "$LOG" 2>&1
    sleep 1
    if sshd_running; then
        log "sshd iniciado (intento $intento)"
        exit 0
    fi
    log "intento $intento falló; reintento en 2 s"
    sleep 2
    intento=$((intento + 1))
done

log "ERROR: no se pudo iniciar sshd"
exit 1
