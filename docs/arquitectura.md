# Arquitectura de la shell (Quickshell / QML)

Código en `parrot/home/.config/quickshell/`. Se lanza con `qs` (desde `exec-once = qs &`). Quickshell 0.3.0 en Parrot, 0.3.1 en Arch.

## Estructura
```
shell.qml              raíz: instancia módulos, GlobalShortcuts (appid "hyprshell"), IpcHandlers ui/wallpaper
config/Theme.qml       singleton: tokens de diseño + paleta (lee ~/.cache/hyprshell/colors.json en vivo)
services/              singletons de datos (pragma Singleton)
  Ui.qml               qué panel está abierto (uno a la vez) y desplegable activo (popout, pantalla, x)
  SysInfo.qml          telemetría (cpu, mem, temps por hwmon, red, disco, uptime, gpu, vram, gateway, mac)
  Notifs.qml           servidor de notificaciones (historial, no molestar, avisos emergentes)
  Wallpapers.qml       lista fondos, miniaturas (themegen --thumbs), aplica (themegen <img>)
  Controls.qml         ajustes rápidos: luz nocturna, cafeína, perfil energía, grabación, color (IPC "control")
  Target/Listeners/Anon  HTB (se quitan en Arch)
widgets/               Icon (glifo Nerd Font por código), Label, Overlay (panel centrado base), Sparkline
modules/
  background/          fondo con fundido (sustituye hyprpaper/awww)
  bar/                 barras por monitor + módulos
  launcher/ wallpaper/ power/     paneles Overlay
  notifications/ osd/  avisos, centro de notificaciones, OSD de volumen/micro
  popouts/             desplegables bajo la barra (red, cpu, gpu, mem, disco, sistema, media, calendario...)
  lock/                pantalla de bloqueo (WlSessionLock + PAM)
  overview/            vista general en vivo (ScreencopyView)
  clipboard/           historial del portapapeles
  control/             centro de control
  packages/            instalador de paquetes
```

## Convenciones
- **Colores**: siempre `Theme.<rol>` (`bg, surface, surface2, overlay, fg, fgMuted, fgDim, accent, accentDim, accent2, red, yellow, green, blue, magenta, cyan`) y `Theme.alpha(color, a)`. Nunca hex fijos (salvo negro/blanco puntuales).
- **Tipografía**: `Theme.fontSans` (Inter), `Theme.fontMono` (JetBrainsMono Nerd Font Propo); `Label { mono: true }`.
- **Iconos**: `Icon { code: 0xf329 }` (código Nerd Font, nunca el carácter pegado: ver lecciones).
- **Animación**: `Easing.BezierSpline` + `Theme.curve`; duraciones `Theme.durFast/durNormal/durSlow` (160/320/600).
- **Paneles**: `Overlay { name: "x" }` + `Ui.toggle("x")`; o `PanelWindow` propio con capa `WlrLayer.Overlay`, `namespace` propio (para `layerrule` de blur) y `keyboardFocus` exclusivo solo cuando está abierto.
- **Monitor**: los paneles abren en `Hyprland.focusedMonitor`.
- **Procesos**: `Process` + `StdioCollector`/`SplitParser`; `Quickshell.execDetached([...])` para lanzar sin esperar.
- **Listas**: patrón del lanzador (ver `lecciones.md` nº 4): `onPositionChanged` con comprobación de posición real y `highlightRangeMode` solo con teclado.

## IPC (`qs ipc call <target> <función>`)
| target | funciones |
|---|---|
| `ui` | `toggle <panel>`, `close`, `pop <nombre> <x>` |
| `wallpaper` | `set <ruta>`, `get` |
| `lock` | `lock`, `preview`, `isLocked`, `debugType <n>`, `debugResult <bool>` (debug solo en preview) |
| `packages` | `open <apt|flatpak>`, `query <texto>` |
| `control` | `caffeine`, `night`, `record`, `profile`, `color`, `dnd`, `state` |

Paneles para `ui toggle`: `launcher, wallpaper, power, notifications, packages, overview, clipboard, control`.

## Integración con Hyprland (`parrot/home/.config/hypr/hyprland.conf`)
- `exec-once`: `qs`, `hypridle`, `hyprpolkitagent`, `wl-paste --watch ~/.local/bin/hyprshell-clip store`, `hyprctl setcursor ...`, `persist-log.sh`.
- `bind = ..., global, hyprshell:<nombre>` para cada atajo de la shell.
- `layerrule = match:namespace hyprshell-<x>, blur on, ignore_alpha <a>` para cada capa con blur.
- `source = ~/.cache/hyprshell/hyprland-colors.conf` (bordes, sombra, `misc:background_color` desde la paleta).
- Reglas: mosaico total (`match:class .*, tile on`) con excepciones flotantes (modales, polkit, portales, imagen-en-imagen), navegadores opacos.

## Ciclo de cambio de fondo
`Super+W` → `WallpaperPicker` → `Wallpapers.set(path)` → `themegen <img>`:
1. `colors.json` → `Theme` (FileView) recolorea la shell con animación.
2. `hyprland-colors.conf` + `hyprctl reload`.
3. `kitty-colors.conf` + `SIGUSR1` a kitty.
4. `parrot.png` (logo teñido para fastfetch).
5. En segundo plano `themegen-apps`: GTK (`~/.themes/hyprshell`), iconos (`~/.local/share/icons/Hyprshell`), Qt (`~/.config/qt6ct/colors/hyprshell.conf`).
6. Neovim vigila `colors.json` y se recolorea solo.
7. Login/arranque **no** (requieren sudo): `build.py` + `install.sh`.
