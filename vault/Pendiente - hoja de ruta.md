# Pendiente - hoja de ruta

## Fase 4 - Bloqueo e inactividad - HECHA (2 oct)
Ver [[Fase 4 - Pantalla de bloqueo]]. Bloqueo a 10 min, monitores apagados a 20, sin suspension. (Sin atenuar: brightnessctl no actua sobre monitores DP de sobremesa.)

## Fase 5 - Login - HECHA (2 oct)
Ver [[Fase 5 - Carga e inicio de sesion]].

## Fase 6 - Apps y terminal
- Temas GTK/Qt con la paleta: HECHO (3 oct), navegadores excluidos. Ver [[Apps con la paleta]].

## Decisiones del usuario
- Atajos: mantener los actuales o volver a los de Arch.
- El "warning" que menciono y no llego a describir.

## Seguridad
- Cambiar la contrasena. Ver [[Seguridad - contrasena]].

Relacionado: [[Resumen del proyecto]].

## Proximo (propuesto el 3 oct)
### Instalador de paquetes (idea de Omarchy) - HECHO (3 oct), ver [[Instalador de paquetes]]
Panel de la shell (mismo estilo que el lanzador), atajo propuesto `Super+I`:
1. Pantalla de **fuentes** compatibles con el sistema (solo las que existen): APT (~72 200 paquetes, pide sudo), Flatpak/Flathub (sin sudo), pip, npm, cargo, go, gem. Snap no esta instalado.
2. **Buscador** difuso; abajo la **descripcion** del paquete seleccionado (version, tamano, si ya esta instalado, fuente).
3. Enter instala: APT abre una terminal pequena para la contrasena; Flatpak instala directo y avisa con notificacion.
4. Pestana **Instalados** para desinstalar.
- Paquetes en varias fuentes (p. ej. Steam en APT y Flatpak) se muestran juntos para elegir.

### GitHub por SSH - HECHO (3 oct), ver [[GitHub por SSH]] (falta user.name/email)
No hay llave SSH ni identidad de git. Clonar repos publicos por HTTPS funciona ya. Para `push`: `ssh-keygen -t ed25519`, anadir `~/.ssh/id_ed25519.pub` en GitHub (Settings -> SSH and GPG keys), `ssh -T git@github.com`, y `git config --global user.name/user.email`.

### Mantenimiento
1. Servicios hostapd-wpe, isc-dhcp-server, sslh desactivados - HECHO (3 oct).
2. `full-upgrade` - HECHO (3 oct): 0 pendientes, kernel 7.1.13 instalado (6.19 se conserva). `parrot.list` actualizado a la version de Parrot (mismos 3 repos activos). Pendiente: `sudo ~/.local/share/hyprshell/boot/fix-plymouth.sh` y reiniciar.
3. `passwd` - pendiente (no cambia la contrasena del disco cifrado).

### Ideas para la sensacion de "falta algo" (propuestas el 3 oct, en este orden)
1. HECHO (3 oct) - ver [[Vista general]]. **Vista general de ventanas** (`Super+Tab`): todos los espacios con miniaturas en vivo; clic para ir, arrastrar para mover.
2. HECHO (3 oct) - ver [[Historial del portapapeles]]. **Historial del portapapeles** (`Super+V`): ultimos ~50 elementos (texto e imagenes) con busqueda. Util para IPs, hashes, payloads.
3. HECHO (3 oct) - ver [[Centro de control]]. **Centro de control rapido**: no molestar, luz nocturna, perfil de energia, VPN/AnonSurf, captura/grabacion, bloqueo.
