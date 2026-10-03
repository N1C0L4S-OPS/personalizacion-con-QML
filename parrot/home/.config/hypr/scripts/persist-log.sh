#!/bin/bash
# Copia el log de Hyprland (vive en /run, se pierde al apagar) a ~/.cache/hypr-logs
# cada 2 s, para poder diagnosticar despues de un apagado forzado.
dest="$HOME/.cache/hypr-logs"
src="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.log"
mkdir -p "$dest"
[ -f "$dest/last.log" ] && mv -f "$dest/last.log" "$dest/prev.log"
hpid=$(pgrep -o -x -u "$USER" 'Hyprland|hyprland')
while kill -0 "$hpid" 2>/dev/null; do
    [ -f "$src" ] && cp -f "$src" "$dest/last.log" && sync "$dest/last.log"
    sleep 2
done
