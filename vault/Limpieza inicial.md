# Limpieza inicial

Limpieza de lo que dejo Antigravity, cada cosa con copia de seguridad.

## Hecho
- **wl-clipboard** instalado: arregla la captura de pantalla (`Super+Shift+S`) y el copiado de puertos.
- **Portales XDG**: se borraron los archivos globales que forzaban el portal de Hyprland tambien dentro de KDE. Ahora cada escritorio usa el suyo.
- **Variables inutiles** fuera de `hyprland.conf`: `WLR_NO_HARDWARE_CURSORS`, `WLR_RENDERER_ALLOW_SOFTWARE`, `LIBINPUT_DEFAULT_KEYBOARD_LAYOUT`.
- **Ruta de hyprpolkitagent** corregida a `/usr/libexec/hyprpolkitagent` (antes no arrancaba; es lo que muestra las ventanas de contrasena de administrador).
- **Teclado es/us** recuperado, se cambia con `Alt+Shift`.
- **logout.sh** ahora cierra los procesos de forma ordenada (sin `kill -9`).
- **extractports** copia con `wl-copy` (antes `xclip`, de X11). Probado: copio `22,80,445`.
- **Paquetes eliminados**: dunst, seatd, lightdm, lightdm-settings, slick-greeter y mas tarde sway-notification-center (swaync).
- **Autostarts rotos** de mate-user-share movidos a la copia de seguridad.
- **zsh** instalado con zsh-autosuggestions y zsh-syntax-highlighting (activacion pendiente).

Relacionado: [[Helpers de HTB]], [[Copias de seguridad y rutas]].
