#!/bin/bash
# Restaura el tema de Plymouth tras una actualizacion e instala la proteccion automatica.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
plymouth-set-default-theme hyprshell
install -m 755 "$SRC/hyprshell-plymouth-guard" /usr/local/sbin/hyprshell-plymouth-guard
install -m 644 "$SRC/99hyprshell-plymouth" /etc/apt/apt.conf.d/99hyprshell-plymouth
echo "==> Regenerando el arranque inicial de todos los kernels (tarda un poco)"
update-initramfs -u -k all
echo
echo "Comprobaciones:"
echo -n "  tema plymouth: "; plymouth-set-default-theme
for k in /boot/initrd.img-*; do
  LIST="$(mktemp)"; lsinitramfs "$k" > "$LIST" 2>/dev/null || true
  printf "  %s: tema=%s llave=%s\n" "$(basename "$k")" \
    "$(grep -q 'themes/hyprshell/hyprshell.script' "$LIST" && echo OK || echo FALTA)" \
    "$(grep -q 'crypto_keyfile.bin' "$LIST" && echo OK || echo FALTA)"
  rm -f "$LIST"
done
echo -n "  proteccion apt: "; [ -f /etc/apt/apt.conf.d/99hyprshell-plymouth ] && echo instalada || echo FALTA
apt-config dump >/dev/null && echo "  configuracion de apt: valida"
