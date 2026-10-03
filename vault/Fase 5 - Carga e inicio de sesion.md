# Fase 5 - Carga e inicio de sesion

Instalado el 2 oct (23:17). El menu de GRUB y la pantalla de la contrasena del disco **no se tocan** (decision del usuario: el arranque funciona y se queda asi).

## Flujo de arranque
1. Firmware -> **GRUB de Arch** (`sdc1`, `\EFI\BOOT\BOOTX64.EFI`): menu de los 3 sistemas. Sin cambios.
2. **GRUB de Parrot** (`sda1`): pide la contrasena de LUKS (texto plano, no personalizable: `/boot` esta dentro del disco cifrado). Sin cambios.
3. **Carga 1** (GRUB leyendo el kernel): ahora **fondo de la paleta con el loro de Parrot**, sin "Loading Linux...". 
4. **Carga 2** (Plymouth, tema `hyprshell`): empieza con la **misma imagen** (no se nota el cambio); el loro gana un brillo que respira y aparece una linea de progreso en el acento.
5. **Inicio de sesion** (SDDM, tema `hyprshell`).

## Inicio de sesion (SDDM)
- Fondo: el wallpaper difuminado y oscurecido (copiado al tema; SDDM no puede leer `~`).
- Reloj 12 h grande, fecha.
- **Usuario escrito a mano, sin caja**: letras sueltas que suben al aparecer, linea de luz que se estira bajo lo escrito, **sugerencia en gris** del nombre (Tab o → completa).
- Enter: el nombre sube y se encoge a rotulo; la linea se contrae en el punto que respira.
- **Contrasena con barras** (como la pantalla de bloqueo): ola al comprobar, temblor rojo y caida si falla, linea de luz si entra.
- Retroceso con la contrasena vacia o Esc: volver al usuario. Aviso de Bloq Mayus.
- Abajo izquierda: sesion (clic para cambiar). Abajo derecha: suspender, reiniciar, apagar.
- Monitor principal: el izquierdo (`Xsetup` con xrandr, DisplayPort-1).

## Archivos
- Fuente: `~/.local/share/hyprshell/boot/` (`build.py` genera recursos con la paleta actual; `install.sh` instala; `revert.sh` deshace).
- Sistema: `/usr/share/sddm/themes/hyprshell/`, `/etc/sddm.conf.d/zz-hyprshell.conf`, `/usr/share/plymouth/themes/hyprshell/`, `/boot/grub/hyprshell-loading.png`, `GRUB_BACKGROUND` en `/etc/default/grub`, `quiet_boot="1"` en `/etc/grub.d/10_linux`.
- Copias: `/var/backups/hyprshell-boot-20261002-231729/`.

## Cambiar de fondo
Los colores de estas pantallas son los del fondo al instalar. Para actualizarlos tras cambiar de wallpaper:
```bash
python3 ~/.local/share/hyprshell/boot/build.py && sudo ~/.local/share/hyprshell/boot/install.sh
```

## Notas
- **Las actualizaciones de Parrot reponen el tema "parrot6"** en `/etc/plymouth/plymouthd.conf` (paso con el `full-upgrade` del 3 oct: el initramfs del kernel 7.1 salio con parrot6). Arreglo: `sudo ~/.local/share/hyprshell/boot/fix-plymouth.sh` (restaura el tema, regenera initramfs de todos los kernels y comprueba tema + llave en cada uno) e instala una **proteccion**: `/etc/apt/apt.conf.d/99hyprshell-plymouth` llama tras cada apt a `/usr/local/sbin/hyprshell-plymouth-guard`, que solo actua si el tema cambio.
- **Pantalla gris tras iniciar sesion** (corregido): era el color de fondo por defecto de Hyprland (`#111111`) mientras la shell carga el wallpaper. themegen ahora escribe `misc:background_color` con el `bg` de la paleta en `hyprland-colors.conf`, asi el paso es tono oscuro de la paleta -> fundido al fondo.
- La entrada principal de GRUB ya no muestra "Loading..."; las 4 de "Opciones avanzadas" si (GRUB siempre las deja).
- Falsa alarma en la primera instalacion: la comprobacion de la llave con `grep -q` cortaba el listado y zstd daba error. Corregido en `install.sh`.

Relacionado: [[Fase 4 - Pantalla de bloqueo]], [[Pendiente - hoja de ruta]].
