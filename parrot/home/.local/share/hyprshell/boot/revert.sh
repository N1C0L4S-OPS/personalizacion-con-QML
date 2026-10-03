#!/bin/bash
# Deshace install.sh usando la ultima copia de seguridad.
set -euo pipefail
BK="$(cat /var/backups/hyprshell-boot-last)"
KVER="$(uname -r)"
echo "Restaurando desde $BK"
cp -a "$BK/plymouthd.conf" /etc/plymouth/plymouthd.conf
cp -a "$BK/grub" /etc/default/grub
cp -a "$BK/10_linux" /etc/grub.d/10_linux
rm -f /etc/sddm.conf.d/zz-hyprshell.conf
cp -a "$BK/Xsetup" /usr/share/sddm/scripts/Xsetup
update-grub
update-initramfs -u -k "$KVER"
echo "Restaurado (tema anterior de Plymouth: $(plymouth-set-default-theme))."
