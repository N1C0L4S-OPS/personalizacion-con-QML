#!/bin/bash
# Instala las pantallas de carga (GRUB sin texto + Plymouth) y el inicio de sesion (SDDM).
# No toca el menu de GRUB ni la pantalla de la contrasena del disco.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
BK="/var/backups/hyprshell-boot-$(date +%Y%m%d-%H%M%S)"
KVER="$(uname -r)"

echo "==> Copias de seguridad en $BK"
mkdir -p "$BK"
cp -a /etc/plymouth/plymouthd.conf /etc/default/grub /etc/grub.d/10_linux "$BK"/
cp -a /etc/sddm.conf.d "$BK"/sddm.conf.d
cp -a /usr/share/sddm/scripts/Xsetup "$BK"/Xsetup
cp -a "/boot/initrd.img-$KVER" "$BK"/
echo "$BK" > /var/backups/hyprshell-boot-last

echo "==> 1/4 Inicio de sesion (SDDM)"
rm -rf /usr/share/sddm/themes/hyprshell
cp -r "$SRC/sddm/hyprshell" /usr/share/sddm/themes/hyprshell
chmod -R a+rX /usr/share/sddm/themes/hyprshell
printf '[Theme]\nCurrent=hyprshell\n' > /etc/sddm.conf.d/zz-hyprshell.conf
# Monitor principal = el izquierdo (DP-2 en Wayland = DisplayPort-1 en X11)
if ! grep -q 'hyprshell' /usr/share/sddm/scripts/Xsetup; then
cat >> /usr/share/sddm/scripts/Xsetup <<'XS'
# hyprshell: monitor izquierdo como principal en el inicio de sesion
xrandr --output DisplayPort-1 --primary --pos 0x0 --output DisplayPort-0 --pos 1920x0 2>/dev/null || true
XS
fi

echo "==> 2/4 Pantalla de carga (Plymouth)"
rm -rf /usr/share/plymouth/themes/hyprshell
cp -r "$SRC/plymouth/hyprshell" /usr/share/plymouth/themes/hyprshell
plymouth-set-default-theme hyprshell

echo "==> 3/4 Carga de GRUB: fondo igual al de Plymouth y sin texto 'Loading...'"
cp "$SRC/grub/background.png" /boot/grub/hyprshell-loading.png
sed -i 's/^quiet_boot="0"/quiet_boot="1"/' /etc/grub.d/10_linux
if grep -q '^GRUB_BACKGROUND=' /etc/default/grub; then
    sed -i 's|^GRUB_BACKGROUND=.*|GRUB_BACKGROUND="/boot/grub/hyprshell-loading.png"|' /etc/default/grub
else
    echo 'GRUB_BACKGROUND="/boot/grub/hyprshell-loading.png"' >> /etc/default/grub
fi
update-grub

echo "==> 4/4 Regenerando initramfs (incluye el tema de Plymouth, tarda un poco)"
update-initramfs -u -k "$KVER"

echo
echo "Comprobaciones:"
echo -n "  tema plymouth: "; plymouth-set-default-theme
# Se lista entero a un archivo (con grep -q el listado se corta y zstd da un falso error)
LIST="$(mktemp)"; lsinitramfs "/boot/initrd.img-$KVER" > "$LIST" 2>/dev/null || true
echo -n "  tema en initramfs: "; grep -q 'themes/hyprshell/hyprshell.script' "$LIST" && echo OK || echo FALTA
echo -n "  llave del disco en initramfs (debe seguir): "; grep -q 'crypto_keyfile.bin' "$LIST" && echo OK || echo FALTA
rm -f "$LIST"
echo -n "  fondo en grub.cfg: "; grep -q hyprshell-loading /boot/grub/grub.cfg && echo OK || echo FALTA
echo -n "  textos Loading en la entrada principal: "; awk "/^menuentry /,/^}/" /boot/grub/grub.cfg | grep -c "echo.*Loading" || true
echo
echo "Listo. Para volver atras: sudo $SRC/revert.sh"
