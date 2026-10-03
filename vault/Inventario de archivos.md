# Inventario de archivos

Todo lo creado o modificado, archivo por archivo.

## Shell Quickshell (`~/.config/quickshell/`) - 55 archivos QML
### Raiz y configuracion
- `shell.qml` - raiz: carga modulos, atajos globales (launcher/wallpaper/power/notifications), IPC (ui, wallpaper), pragma de iconos breeze-dark.
- `config/Theme.qml` - paleta y tokens (ver [[Valores y ajustes exactos]]).

### services/ (singletons de datos)
- `Ui.qml` - que panel/desplegable esta abierto (uno a la vez), posicion del desplegable.
- `SysInfo.qml` - telemetria: CPU, memoria, temperaturas (por nombre de hwmon), red, disco, uptime, IP de VPN, GPU busy, VRAM, puerta de enlace, MAC, modelo de CPU, e historiales para las graficas.
- `Notifs.qml` - servidor de notificaciones (reemplaza swaync): historial, no molestar, avisos.
- `Wallpapers.qml` - lista los fondos, genera miniaturas, aplica uno (llama a themegen).
- `Target.qml` - objetivo HTB (IP, nombre, hora de inicio, cronometro).
- `Listeners.qml` - puertos en escucha (`ss -tlnpH`), detecta handlers de reverse shell.
- `Anon.qml` - estado de AnonSurf/Tor, alterna abriendo terminal.

### widgets/ (reutilizables)
- `Icon.qml`, `Label.qml` - texto e iconos con la paleta.
- `Overlay.qml` - ventana flotante centrada con animacion (base de launcher/wallpaper/power).
- `Sparkline.qml` - grafica de linea con relleno (CPU/GPU/red).

### modules/background/
- `Background.qml` - fondo de pantalla con fundido (reemplaza hyprpaper).

### modules/bar/
- `Bar.qml` - barra flotante por monitor; decide barra principal vs secundaria.
- `Prompt.qml` - usuario@host (cursor parpadeante quitado el 2 oct a peticion del usuario).
- `Workspaces.qml` - espacios 1-5 / 6-0 segun monitor.
- `WindowTitle.qml` - titulo de la ventana activa.
- `Clock.qml` - reloj 12 h (centro de la principal); clic abre el calendario.
- `HtbTarget.qml` - objetivo + cronometro de maquina.
- `Htb.qml` - logo HTB + estado VPN (disconnected rojo / IP verde).
- `ListenersButton.qml` - contador de listeners (pulso verde si hay handler).
- `RevShellButton.qml` - abre el menu de reverse shells.
- `AnonButton.qml` - estado AnonSurf.
- `AudioControl.qml` - volumen y microfono (un mismo componente).
- `NotifButton.qml` - campana (clic abre centro, derecho = no molestar).
- `PowerButton.qml` - abre el menu de energia.
- `Media.qml` - reproductor o fecha larga (centro de la secundaria).
- `Spectrum.qml` - espectro de audio con cava (centro de la secundaria, a la izquierda del reproductor).
- `SysStats.qml` - telemetria interactiva (secundaria).
- `Separator.qml` - separador vertical.

### modules/launcher/ · wallpaper/ · power/
- `Launcher.qml`, `WallpaperPicker.qml`, `PowerMenu.qml`.

### modules/notifications/ · osd/
- `NotifCard.qml`, `Popups.qml`, `NotifCenter.qml`, `VolumeOsd.qml`.

### modules/popouts/ (paneles interactivos de la barra secundaria)
- `Popouts.qml` (contenedor), `PopHeader.qml`, `InfoRow.qml`, `Meter.qml`, `ProcList.qml`, `ActionButton.qml`.
- Contenidos: `NetPop.qml`, `CpuPop.qml`, `GpuPop.qml`, `MemPop.qml`, `DiskPop.qml`, `SysPop.qml`, `MediaPop.qml`, `RevShellPop.qml`, `ListenersPop.qml`, `CalendarPop.qml`.

### modules/lock/
- `Lock.qml`, `LockSurface.qml`, `PassBars.qml`. Ver [[Fase 4 - Pantalla de bloqueo]].

## Fuera de la shell
- `~/.local/bin/themegen` - generador de paleta y miniaturas.
- `~/.local/bin/themegen-apps` - temas GTK/Qt/iconos con la paleta. Ver [[Apps con la paleta]]. Ver [[themegen - paleta desde el fondo]].
- `~/.config/cava/hyprshell.conf` - cava en modo raw (20 barras, 50 fps, pulse, sleep_timer 2).
- `~/.config/hypr/hypridle.conf` - inactividad y bloqueo.
- `~/.config/hypr/scripts/persist-log.sh` - guarda el log de Hyprland.
- `~/.config/hypr/scripts/logout.sh` - cierre de sesion ordenado.
- `~/.config/hypr/hyprland.conf` - editado. Ver [[Cambios exactos en hyprland.conf]].
- `~/.config/kitty/kitty.conf` - colores ahora por `include` de themegen.
- `~/.config/htb_helpers.sh` - `settarget` guarda la hora, `extractports` usa wl-copy. Ver [[Helpers de HTB]].

Relacionado: [[Cambios exactos en hyprland.conf]], [[Valores y ajustes exactos]].
