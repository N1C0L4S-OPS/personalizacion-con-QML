# Arranque y login

## Cómo quedó en Parrot
Cadena: firmware → **GRUB de Arch** (menú 3 SO) → GRUB de Parrot pide la contraseña LUKS (texto, no personalizable porque `/boot` está cifrado) → **carga 1** (GRUB cargando el kernel: fondo `hyprshell-loading.png` = primer fotograma de Plymouth, sin "Loading Linux...") → **carga 2** (Plymouth `hyprshell`: mismo fotograma, el loro gana brillo que respira y aparece una línea de progreso) → **SDDM** `hyprshell` → Hyprland (color de fondo = `bg` de la paleta, sin flash gris).

Fuentes: `parrot/home/.local/share/hyprshell/boot/`
- `build.py` genera con la paleta actual: fondo difuminado del login, `theme.conf` con colores, fuente de iconos, imágenes de Plymouth y el fondo de GRUB.
- `install.sh` (sudo) instala y verifica; `revert.sh` deshace; `fix-plymouth.sh` + `hyprshell-plymouth-guard` + `99hyprshell-plymouth` (hook de apt) restauran el tema si una actualización lo cambia.
- `sddm/hyprshell/Main.qml`: **usuario escrito a mano sin caja** (letras sueltas que suben, línea de luz bajo lo escrito, sugerencia en gris + Tab completa), Enter → el nombre sube a rótulo y la línea se contrae en el punto que respira → **contraseña con barras** (igual que el bloqueo). Sesión abajo-izq (clic cambia), energía abajo-dcha, aviso Bloq Mayús, monitor principal forzado con `xrandr` en `Xsetup`.
- `plymouth/hyprshell/hyprshell.script`: script de Plymouth (variables de estado con `global.`; si alguna vez se pidiera contraseña en Plymouth, también dibuja barras).

Probar SDDM **sin cerrar sesión**: `sddm-greeter-qt6 --test-mode --theme <dir>`. Para animaciones sin teclado, una copia del tema con un `Timer` que llame a `uAdd/toPass/addChar` (así se hizo; no dejes ese código en el tema real).

## En Arch
- **Sin LUKS**: no hay pantalla de contraseña de disco. Más sencillo.
- **Plymouth**: `sudo pacman -S plymouth`; añadir `plymouth` a `HOOKS` en `/etc/mkinitcpio.conf` **después de `kms`** (p. ej. `... modconf kms plymouth keyboard ...`), `splash` en `GRUB_CMDLINE_LINUX_DEFAULT` (ya tiene `quiet`), `sudo plymouth-set-default-theme -R hyprshell` (regenera con mkinitcpio). Logo: el de Arch teñido (cambia `build.py`).
- **Protección ante actualizaciones**: hook de pacman en `/etc/pacman.d/hooks/hyprshell-plymouth.hook` (Trigger: Package plymouth / Target `usr/share/plymouth/*`; Action: `Exec = /usr/local/sbin/hyprshell-plymouth-guard` adaptado a `mkinitcpio -P`).
- **GRUB de Arch**: es el que arranca **toda** la máquina (Parrot y Windows incluidos). Tiene tema Elegant-mojave y `GRUB_TIMEOUT=300` con menú visible. El "fondo de carga" de Parrot no aplica igual aquí (el menú es visible). **No lo modifiques sin permiso explícito**; si lo haces, `grub-mkconfig -o /boot/grub/grub.cfg` y prueba que siguen apareciendo los 3 sistemas (os-prober).
- **SDDM en Arch (comprobado el 3 oct)**: tema actual `sugar-candy`, cursor `Ghostline-Dark`. **Configuración contradictoria**: `/etc/sddm.conf` dice `DisplayServer=x11` (con `Xsetup` y `-dpi 96`) y `/etc/sddm.conf.d/wayland.conf` dice `DisplayServer=wayland` con `CompositorCommand=uwsm start -- hyprland.desktop`. En SDDM `/etc/sddm.conf` tiene prioridad, así que probablemente gana X11: **compruébalo** (`journalctl -b -u sddm`) y deja una sola fuente de verdad. El tema QML funciona igual (`QtVersion=6`); el truco de `xrandr` en `Xsetup` es solo para X11. Nombres de salida en X11 con amdgpu: `DisplayPort-0/1`, `HDMI-A-0`. Con 3 monitores, elige el principal (DP-2) con él.
- **Respaldo**: antes de reiniciar, ten un plan (otro kernel/initramfs fallback, TTY, `revert`). Haz el primer reinicio con el usuario delante.
