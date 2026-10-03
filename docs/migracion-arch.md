# Migración a Arch, archivo por archivo

Origen: `parrot/home/...` (rutas relativas a `~`). Destino: el `~` del usuario `seth` en Arch.
Antes de copiar cada archivo: **haz copia del que haya en Arch** y aplica los cambios de esta lista. Después, **verifica**.

Convención: **[Q]** quitar (HTB), **[C]** cambiar, **[A]** añadir, **[=]** igual.

---

## Fase 0: preparación

1. Copia de seguridad: `~/.config`, `~/.local/bin`, `~/.zshrc`, `pacman -Qqe > ~/paquetes-antes.txt`. Pregunta si usa timeshift o snapper antes de tocar el arranque.
2. **Login: LightDM → SDDM.** Es el fallo nº 1: en Parrot, LightDM (slick-greeter sobre Xorg) arrancaba Hyprland en la misma terminal virtual y se peleaban por los dispositivos de entrada, así que a veces no respondían teclado ni ratón. Pregúntale si en Arch lo ha notado; aun así, cámbialo:
   `sudo systemctl disable lightdm && sudo systemctl enable sddm` (SDDM ya está instalado). Comprueba `/etc/sddm.conf.d/` y que exista la sesión `hyprland.desktop`.
3. Instala los paquetes del README §7.
4. **Decide los atajos con él** (README §6) y apúntalos en la bóveda antes de escribir nada.

---

## Fase 1: shell base

### `~/.local/bin/themegen` [C]
- `[=]` todo el análisis (k-means OKLab, `pick`, `build_palette`).
- `[C]` `write_logo()`: hoy tiñe la máscara del loro de Parrot (`~/.local/share/hyprshell/parrot-wings-mask.png`). En Arch: genera la máscara desde `/usr/share/pixmaps/archlinux-logo.svg` (o el glifo U+F303) con `convert -background none -density 6000 ... -resize 2400x`, y renómbrala (`arch-logo-mask.png`). Ajusta `LOGO_CELLS` según la proporción del logo y mide la celda de kitty (`kitten icat --print-window-size` + `tput cols/lines`): en Parrot era 9×21 px.
- `[C]` `reload_apps()`: igual (hyprctl reload + `pkill -USR1 -x kitty`).
- `[=]` sigue lanzando `themegen-apps` en segundo plano.
- `[A]` opcional: aceptar `themegen --palette <colors.json>` para los **temas con nombre** de `~/.config/omarchy-theme/themes/*/colors.json` (ver `uso-diario.md`).

### `~/.config/quickshell/` (raíz `shell.qml`)
- `[Q]` imports y uso de lo HTB (ver lista al final). `[=]` el resto.
- `[A]` `SystemTray` en la barra (ver `uso-diario.md`).

### `config/Theme.qml` [C]
- `primaryMonitor: "DP-2"` sigue valiendo (en Arch DP-2 también es el principal, abajo-izquierda). `[Q]` `htbGreen`.
- `[=]` tokens, curva, duraciones, `maxVolume: 1.5` (pregúntale si quiere 150 % en uso diario).

### `modules/bar/Bar.qml` [C]
- Hoy: principal (DP-2) = contexto + módulos HTB; secundaria (el resto) = telemetría. En Arch hay **3** monitores: decide con él qué muestra el HDMI de arriba (propuesta: barra mínima con reloj y reproductor, o ninguna).
- `[Q]` `Prompt`, `HtbTarget`, `Htb`, `ListenersButton`, `RevShellButton`, `AnonButton` y sus `Separator`.
- `[A]` `SystemTray`, indicador de actualizaciones, pomodoro, próximo evento (ver `uso-diario.md`).
- **Recomendación fuerte**: en Parrot el usuario sintió que "algo faltaba" y la causa probable eran **barras demasiado cargadas** (IP, kB/s, temperaturas, porcentajes siempre visibles) frente a su objetivo "minimalista y sofisticado". En Arch, empieza **limpio**: iconos discretos y los números en los desplegables (que ya existen).

### `modules/bar/Workspaces.qml` [C]
- Hoy: 1-5 en el principal, 6-0 en el otro. En Arch: 1-5 `DP-2`, 6-10 `DP-1`, 11-15 `HDMI-A-1` (eso ya está en su `hyprland.conf`). Generaliza el rango por monitor (mapa `nombre → [ids]`) en vez de "principal / resto".

### `services/SysInfo.qml` [C]
- `[Q]` `vpnIp` ligado a `tun0` (HTB). Si usa otra VPN (WireGuard...), cambia la interfaz o quítalo.
- `[=]` CPU, memoria, temperaturas (por nombre de hwmon: k10temp/amdgpu, mismo hardware), red, disco, uptime, GPU (libdrm "AMD Radeon RX 7600").

### `modules/background/Background.qml` [=]
Sustituye a **awww**: quita `awww` del `exec-once` cuando funcione. Los fondos de Arch están en su carpeta (busca en `wallpaper-selector.sh`), ajusta `services/Wallpapers.qml` (`directory`).

---

## Fase 2: paneles

| Archivo | Acción |
|---|---|
| `modules/launcher/Launcher.qml` | `[=]` (incluye el arreglo de hover y desplazamiento). Sustituye a `rofi -show drun`. |
| `modules/wallpaper/WallpaperPicker.qml` | `[=]` Sustituye al selector de rofi. Miniaturas: `themegen --thumbs <dir>`. |
| `modules/power/PowerMenu.qml` | `[=]` Sustituye a `powermenu.sh` / wlogout. |
| `modules/notifications/*` + `services/Notifs.qml` | `[=]` Sustituye a **dunst**: quita dunst del arranque (dos servidores de notificaciones chocan). |
| `modules/osd/VolumeOsd.qml` | `[=]` Sustituye a `osd.sh`/swayosd. `[A]` si quiere brillo: DDC (`ddcutil`), ver `uso-diario.md`. |
| `modules/popouts/*` | `[Q]` `RevShellPop`, `ListenersPop`; `[C]` `NetPop` sin IP de HTB; `[=]` Cpu/Gpu/Mem/Disk/Sys/Media/Calendar. |
| `modules/bar/Media.qml` + `Spectrum.qml` | `[=]` (cava: `~/.config/cava/hyprshell.conf`). Útil para Spotify. |
| `modules/bar/Clock.qml` + `popouts/CalendarPop.qml` | `[=]` 12 h. `[A]` eventos de khal en el calendario. |

---

## Fase 3: bloqueo

- `modules/lock/*` `[=]`. Usa PAM `config: "hyprlock"`: en Arch **existe** `/etc/pam.d/hyprlock` con `auth include login` (comprobado), así que funciona igual.
- `~/.config/hypr/hypridle.conf` `[C]` tiempos que elija. El `lock_cmd` usa `qs ipc call lock lock` con respaldo `hyprlock`.
- `hyprland.conf`: `misc { allow_session_lock_restore = true }` y `Super+L → loginctl lock-session`.
- Prueba primero `qs ipc call lock preview` (no bloquea; Esc sale). Para probar animaciones sin contraseña: `qs ipc call lock debugType 8` y `debugResult true|false` (solo en modo prueba).

---

## Fase 4: productividad

- `modules/overview/Overview.qml` `[C]` 3 monitores: `wsIds` por monitor (1-5, 6-10, 11-15).
- `modules/clipboard/Clipboard.qml` + `~/.local/bin/hyprshell-clip` `[=]`. Sustituye a cliphist + rofi (quita `wl-paste --watch cliphist store`; arranca `wl-paste --watch ~/.local/bin/hyprshell-clip store`). Historial en RAM.
- `modules/control/ControlCenter.qml` + `services/Controls.qml` + `modules/bar/ControlButton.qml` `[C]` `[Q]` casillas AnonSurf y VPN HTB; `[A]` para uso diario: modo juego, pomodoro, VPN genérica si la usa.
- `modules/packages/Packages.qml` + `~/.local/bin/hyprshell-pkg` `[C]` **es la pieza que más cambia**:
  - Fuente **APT → pacman** (repos oficiales): lista `pacman -Sl` (o `expac -S '%n\t%d'`), instalados `pacman -Qq`, ficha `pacman -Si`, instalar `sudo pacman -S`, quitar `sudo pacman -Rns`.
  - **[A] AUR** con `yay`: búsqueda por red (`yay -Ssa` o la API RPC de AUR `https://aur.archlinux.org/rpc/v5/search/...`), con *debounce*; instalar con `yay -S` en la terminal flotante (pide confirmar PKGBUILD: no ocultes eso al usuario).
  - Flatpak `[=]` (catálogo appstream en `~/.local/share/flatpak/appstream/flathub/x86_64/*/appstream.xml.gz`).
  - **[A] Pestaña "Actualizaciones"**: `checkupdates` (pacman-contrib) + `yay -Qua` + `flatpak remote-ls --updates`; botón "Actualizar todo" = `sudo pacman -Syu` + `yay -Sua` + `flatpak update` en la terminal flotante. Sustituye a `system-update.sh` y al módulo `custom/updates`.
  - Iconos de fuente: Arch U+F303, AUR (glifo de paquete), Flathub U+F324.

---

## Fase 5: uso diario
Ver `uso-diario.md`.

---

## Fase 6: apps, cursor, animaciones

### `~/.local/bin/themegen-apps` [C]
- Base GTK: en Parrot era **ARK-Dark (Arc)** recoloreado (`/usr/share/themes/ARK-Dark/gtk-3.22`). En Arch no existe: usa **`adw-gtk-theme`** (`/usr/share/themes/adw-gtk3-dark`) como base. Adwaita usa otros colores de partida: vuelve a medir sus colores (`collections.Counter` de hex en su `gtk.css`) y ajusta `remap()` (qué es "gris de fondo" y cuál es el "acento", hoy `#5294e2` de Arc; en adw-gtk3 el acento por defecto es `#3584e4`). Alternativa más simple con adw-gtk3: **solo un `gtk.css` con `@define-color`** (accent_bg_color, window_bg_color, view_bg_color, headerbar_bg_color, card_bg_color...) en `~/.config/gtk-3.0/gtk.css` y `gtk-4.0/gtk.css`; adw-gtk3 y libadwaita respetan esos nombres. Pruébalo: probablemente sea **mejor** que el recoloreado de imágenes.
- Iconos: en Parrot, Flat-Remix-Green-Dark con las carpetas recoloreadas. En Arch usa Papirus (paquete `papirus-icon-theme`) y recolorea sus carpetas igual (sus SVG de carpeta tienen pocos colores) en `~/.local/share/icons/Hyprshell` con `Inherits=Papirus-Dark`.
- Qt: `~/.config/qt6ct/` `[=]`; en `hyprland.conf` cambia `QT_QPA_PLATFORMTHEME,qt5ct` → `qt6ct` (las apps Qt5 que queden pueden seguir con qt5ct: pregunta).
- Navegadores excluidos: en Parrot, copias de `.desktop` con `Exec=env GTK_THEME=ARK-Dark ...`. En Arch: `GTK_THEME=adw-gtk3-dark` (o el que use) para Brave/Firefox, si él lo sigue queriendo.
- **Solo en Hyprland**: variables `env` en `hyprland.conf`, no en archivos globales (tiene KDE/otras sesiones).

### Cursor [C]
Bibata-Modern-Classic (AUR `bibata-cursor-theme-bin`); hoy usa `Ghostline-Dark`: **pregúntale** antes de cambiarlo. Puntos donde se define: `env XCURSOR_THEME`, `exec-once hyprctl setcursor`, gsettings, `gtk-3.0/4.0 settings.ini`, `~/.icons/default/index.theme`, `/etc/sddm.conf.d/`.

### Animaciones [C]
Sustituye su bloque `animations` por el de `parrot/home/.config/hypr/hyprland.conf` (curvas `emphasized` / `emphasizedAccel` / `standard`, sin rebote). En Hyprland 0.56 comprueba nombres de animación con `hyprctl configerrors`.

---

## Fase 7: terminal y Neovim
Ver `terminal-y-nvim.md`.

---

## Fase 8: arranque y login
Ver `arranque-y-login.md`. **El GRUB de Arch arranca toda la máquina**: el usuario decidió **no personalizar GRUB** en Parrot; en Arch ya tiene el tema Elegant-mojave y `GRUB_TIMEOUT=300`. No lo toques sin pedírselo.

---

## Lista exacta de lo HTB a quitar

| Archivo (en `parrot/home/`) | Qué es |
|---|---|
| `.config/quickshell/modules/bar/Prompt.qml` | `user@host:~` estilo terminal |
| `.config/quickshell/modules/bar/HtbTarget.qml` | objetivo + cronómetro de máquina |
| `.config/quickshell/modules/bar/Htb.qml` | logo HTB + estado VPN tun0 |
| `.config/quickshell/modules/bar/ListenersButton.qml` | puertos en escucha / handlers de reverse shell |
| `.config/quickshell/modules/bar/RevShellButton.qml` | menú de reverse shells |
| `.config/quickshell/modules/bar/AnonButton.qml` | AnonSurf/Tor |
| `.config/quickshell/modules/popouts/RevShellPop.qml`, `ListenersPop.qml` | sus desplegables |
| `.config/quickshell/services/Target.qml`, `Listeners.qml`, `Anon.qml` | sus servicios |
| `services/SysInfo.qml` (`vpnIp`), `popouts/NetPop.qml` (IP VPN), `popouts/Popouts.qml` (entradas revshell/listeners), `shell.qml` (`onPrimary` de esos desplegables) | referencias |
| `services/Controls.qml` / `modules/control/ControlCenter.qml` | casillas AnonSurf y VPN HTB, `openvpn` |
| `config/Theme.qml` | `htbGreen` |
| `.config/htb_helpers.sh` | settarget, cleartarget, mktarget, pingtarget, extractports, vpnstatus (los alias de eza/bat, fzf y `BAT_THEME` **sí** se conservan: muévelos a `.zshrc`) |
| `.config/starship.toml` | `env_var.TARGET_NAME`, `env_var.TARGET_IP` |
| `.config/fastfetch/config.jsonc` | bloque vpn / target |
| `.config/hypr/hyprland.conf` | regla `htb-target` |

Comprobación: `grep -rniE 'htb|target|tun0|anon|revshell|listener' ~/.config/quickshell ~/.config/starship.toml ~/.config/fastfetch ~/.zshrc` debe quedar vacío (salvo palabras sueltas sin relación).
