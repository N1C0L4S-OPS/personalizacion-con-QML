# Uso diario: qué añadir en Arch

Parrot se orientó a HTB. Arch es para el día a día (juegos, Discord, Spotify, Zoom, LibreOffice, programación). Esto es lo que **no existe** en la shell de Parrot y el uso diario pide. Varias cosas ya las tiene en waybar/rofi: aquí se rehacen en QML con el mismo estilo.

Prioridad sugerida: 1 → 2 → 3 → resto según lo que él pida. **Pregúntale** antes de cada una; no las impongas.

---

## 1. Bandeja del sistema (imprescindible)
Discord, Steam, Spotify, Zoom, nm-applet... viven en la bandeja. Sin ella no se pueden abrir/cerrar bien.
- Quickshell: `import Quickshell.Services.SystemTray` → `SystemTray.items` (cada `SystemTrayItem` tiene `icon`, `tooltipTitle`, `activate()`, `secondaryActivate()`, `menu` para el menú contextual con `QsMenuAnchor`/`QsMenuOpener`).
- En la barra principal, a la derecha, iconos monocromos o atenuados hasta pasar el ratón (coherente con el estilo).
- Comprueba que **dunst/waybar ya no estén corriendo** (la bandeja solo puede tenerla un host a la vez en algunos casos).

## 2. Barras limpias (la sensación de "falta algo")
En Parrot el usuario sintió que algo faltaba. Diagnóstico: el escritorio se veía siempre igual (ventanas a pantalla completa + dos barras **muy cargadas** de números), contradiciendo su objetivo "minimalista, elegante y sofisticado". Propuesta para Arch:
- Barra principal: espacios, título, reloj, reproductor, bandeja, audio, notificaciones, centro de control. Nada de kB/s ni temperaturas a la vista.
- Telemetría: un solo icono (o ninguno) que abre el desplegable de sistema; números solo dentro.
- Considera **margen alrededor de las ventanas** (gaps_out 14-20, ya tiene 20), sombra más profunda y **atenuar ventanas inactivas** (`decoration:dim_inactive`, `dim_strength 0.08`) para que el fondo y la ventana activa respiren.
- Haz primero una **maqueta** (captura editada o un QML de prueba) y que él decida.

## 3. Instalador con actualizaciones
Ver `migracion-arch.md` (fase 4): pacman + AUR + Flatpak, y pestaña **Actualizaciones** con contador en la barra (sustituye a `custom/updates` y `system-update.sh`). Comprobar cada 30-60 min con `checkupdates` (no requiere root) + `yay -Qua` + `flatpak remote-ls --updates`.

## 4. Pomodoro
Ya lo tiene en waybar (`waybar/scripts/pomodoro.sh`, estado en `/tmp/pomodoro_*`). Rehacer como servicio QML (`services/Pomodoro.qml`): 25/5 min configurables, anillo de progreso fino en la barra, notificación al terminar cada fase, clic inicia/pausa, clic derecho reinicia. Persistir solo en memoria.

## 5. Próximo evento (calendario)
Ya usa **khal** (`next_event.sh`: `khal list now 7days`). Integrar en el desplegable del calendario (`CalendarPop.qml`): puntos en los días con eventos, lista de los próximos debajo del mes, y en la barra solo el próximo evento si es en < 1 h.

## 6. Notas rápidas
Ya tiene `quicknotes.sh` (`~/.local/share/quicknotes.md`, líneas con fecha). Panel QML como el portapapeles: escribir y Enter añade; lista con búsqueda; Enter copia. Atajo a decidir.

## 7. Temas con nombre + paleta desde el fondo
Tiene `~/.config/omarchy-theme/themes/<nombre>/{colors.json,wallpaper.png}` y `theme-set.sh`. Unificar:
- `themegen <imagen>`: paleta desde el fondo (lo de siempre).
- `themegen --theme <nombre>`: usa el `colors.json` del tema (mapear sus claves a las de `colors.json` de hyprshell: bg, surface, surface2, overlay, fg, fgMuted, fgDim, accent, accentDim, accent2, red, yellow, green, blue, magenta, cyan) y su fondo.
- En el selector de fondos (`WallpaperPicker`) una pestaña "Temas" con las muestras de color.

## 8. Modo juego
Para Steam/Proton:
- Cuando una ventana entra en pantalla completa (o su clase es un juego: `steam_app_*`, `gamescope`), desactivar blur, sombras y animaciones (`hyprctl --batch "keyword animations:enabled 0; keyword decoration:blur:enabled 0; keyword decoration:shadow:enabled 0"`) y restaurar al salir. Escuchar el socket de eventos de Hyprland (`fullscreen>>`, `activewindow>>`) desde un servicio QML (`Hyprland.rawEvent`).
- Casilla en el centro de control: "Modo juego" (lo anterior + `gamemoded` + perfil de energía Rendimiento + no molestar).
- Regla: `windowrule = match:class ^(steam_app_.*)$, immediate on` (tearing permitido) si él lo quiere; comprueba sintaxis en 0.56.

## 9. Brillo de monitores (opcional)
Monitores de sobremesa: `ddcutil setvcp 10 <0-100> --display N`. Es lento (~0,5 s): aplicar al soltar el deslizador, no en cada píxel. Deslizador en el centro de control y OSD con las teclas de brillo si su teclado las tiene.

## 10. Otras ideas que surgieron en Parrot (no hechas)
- **Sonidos** sutiles y a juego (notificación, captura, bloqueo/desbloqueo, inicio de sesión): `pw-play` con archivos `.oga` cortos; casilla para silenciarlos.
- **Escritorio vacío con presencia**: reloj discreto sobre el fondo en los espacios sin ventanas (misma familia que el del bloqueo).
- VPN genérica (WireGuard/NetworkManager) en el centro de control si la usa.
