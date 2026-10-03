# Vista general

`Super+Tab` (otra vez `Super+Tab` o `Esc` para salir). Modulo `~/.config/quickshell/modules/overview/Overview.qml`.

## Que muestra
- En **cada monitor** sus 5 espacios (izquierdo 1-5, derecho 6-0) como miniaturas de la pantalla: el fondo de pantalla (miniatura de themegen) y **las ventanas en vivo** (ScreencopyView, se mueven los videos) en su posicion y tamano reales, con el icono de la app.
- Espacio activo con borde y numero en el acento; los vacios dicen "vacio".
- Debajo: titulo, icono, clase y espacio de la ventana bajo el raton o seleccionada (o "Espacio N · X ventanas").
- Fondo difuminado (`layerrule` para `hyprshell-overview`) y entrada escalonada de las miniaturas.

## Controles
| Accion | Raton | Teclado |
|---|---|---|
| Ir a una ventana | clic | `Tab` / `↓` elegir, `Enter` |
| Ir a un espacio | clic en zona vacia | `←/→` + `Enter`, o `1`-`5` |
| Mover ventana a otro espacio | arrastrar a la miniatura destino (se resalta) | - |
| Cerrar ventana | clic central | `Supr` |
| Salir | clic fuera | `Esc` o `Super+Tab` |

## Tecnico
- Datos: `Hyprland.toplevels` (direccion, espacio, `lastIpcObject.at/size`, enlace `wayland` para la captura). Se refrescan al abrir y tras mover/cerrar.
- Ordenes: `workspace N`, `focuswindow address:0x...`, `movetoworkspacesilent N,address:0x...`, `closewindow address:0x...` (probadas con una ventana de prueba).
- Teclado solo en el monitor con el foco; capturas en vivo solo mientras esta abierta.

Relacionado: [[Monitores y espacios de trabajo]], [[Atajos de teclado]].
