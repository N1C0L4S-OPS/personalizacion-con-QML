# Arquitectura de la shell (Quickshell)

Shell propia escrita en **QML** con **Quickshell 0.3.0**, en `~/.config/quickshell/`. Reemplaza a waybar, rofi, swaync y hyprpaper con una sola base coherente.

## Estructura de carpetas
- `shell.qml` - raiz: carga todos los modulos, atajos globales y la IPC.
- `config/Theme.qml` - paleta y tokens de diseno (tipografia, radios, animaciones, colores). Lee `~/.cache/hyprshell/colors.json`.
- `services/` - singletons de datos: `Ui` (que panel esta abierto), `SysInfo` (telemetria), `Notifs`, `Wallpapers`, `Target`, `Listeners`, `Anon`.
- `widgets/` - piezas reutilizables: `Icon`, `Label`, `Overlay`, `Sparkline`.
- `modules/` - lo visible: `background/`, `bar/`, `launcher/`, `wallpaper/`, `power/`, `notifications/`, `osd/`, `popouts/`.

## Ideas clave
- Los colores vienen del fondo (ver [[themegen - paleta desde el fondo]]) y cambian con animacion.
- Curva de animacion tipo "emphasized" para el aire estilo Caelestia.
- Un solo panel/desplegable abierto a la vez (servicio `Ui`).

## IPC util
```bash
qs ipc call wallpaper set <ruta>     # cambiar fondo
qs ipc call ui toggle launcher       # abrir/cerrar lanzador
qs ipc call ui pop <modulo> <x>      # abrir un desplegable (pruebas)
```

## Gotcha
El QML que se carga con `Loader` (los desplegables) queda en cache: tras editarlo hay que **reiniciar `qs`**.

Relacionado: [[Barra superior]], [[Fase 2 - Lanzador, fondos y energia]], [[Fase 3 - Notificaciones y volumen]].
