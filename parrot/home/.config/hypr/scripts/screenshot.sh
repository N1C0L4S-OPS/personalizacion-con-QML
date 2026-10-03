#!/usr/bin/env bash
# Captura de pantalla: guarda en ~/Pictures/Capturas, copia al portapapeles (imagen) y avisa.
#   screenshot.sh zona      -> seleccionar con el raton  (Super+Shift+S)
#   screenshot.sh pantalla  -> monitor bajo el raton     (Impr Pant)
#   screenshot.sh ventana   -> ventana activa            (Super+Impr Pant)
set -euo pipefail

dir="$HOME/Pictures/Capturas"
mkdir -p "$dir"
file="$dir/Captura_$(date +%Y-%m-%d_%H-%M-%S).png"

# Colores de la paleta actual para el recuadro de seleccion
colors="$HOME/.cache/hyprshell/colors.json"
get() { grep -oP "\"$1\": \"#\K[0-9a-fA-F]{6}" "$colors" 2>/dev/null || echo "$2"; }
accent=$(get accent 7fb3ad)
bg=$(get bg 0e1111)

case "${1:-zona}" in
    zona)
        geom=$(slurp -d -b "${bg}88" -c "${accent}ff" -s "${accent}22" -w 2 -B "${bg}66" -F "JetBrainsMono Nerd Font") || exit 0
        grim -g "$geom" "$file" ;;
    pantalla)
        mon=$(hyprctl monitors -j | python3 -c "import json,sys;print(next(m['name'] for m in json.load(sys.stdin) if m['focused']))")
        grim -o "$mon" "$file" ;;
    ventana)
        geom=$(hyprctl activewindow -j | python3 -c "import json,sys;w=json.load(sys.stdin);print(f\"{w['at'][0]},{w['at'][1]} {w['size'][0]}x{w['size'][1]}\")")
        grim -g "$geom" "$file" ;;
    *) echo "uso: $0 zona|pantalla|ventana"; exit 1 ;;
esac

wl-copy --type image/png < "$file"
notify-send -a "Captura" -i "$file" -h "string:image-path:$file" \
    "Captura copiada" "Pega con Ctrl+V · guardada en Imágenes/Capturas"
