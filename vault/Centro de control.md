# Centro de control

`Super+C` o el boton de ajustes de la barra principal (junto a la campana). Esc o clic fuera cierra.

## Contenido
- **Cabecera**: usuario (logo Parrot), tiempo encendido, bloquear, menu de energia.
- **Volumen y microfono**: barras arrastrables (y rueda) hasta 150 %, marca del 100 %, amarillo por encima; clic en el icono silencia.
- **Ajustes rapidos** (casillas):
  | Casilla | Que hace | Requiere |
  |---|---|---|
  | No molestar | solo avisos criticos | - |
  | Luz nocturna | pantalla calida (4200 K) | `hyprsunset` |
  | Cafeina | impide bloqueo y apagado de monitores (inhibidor de systemd, hypridle lo respeta); taza amarilla en la barra | - |
  | Energia | cicla Ahorro -> Equilibrado -> Rendimiento | `powerprofilesctl` |
  | AnonSurf | alterna Tor (abre terminal para sudo) | - |
  | VPN HTB | IP de tun0 (clic copia) | `openvpn` para conectar |
  | Grabar pantalla | graba el monitor con el foco en `~/Videos/Grabaciones/`; boton de la barra en rojo latiendo; aviso al guardar | `wf-recorder` |
  | Selector de color | elige un pixel y copia el hex | `hyprpicker` |
  - Sin su herramienta, la casilla sale atenuada con "no instalado · paquete" y se activa sola al instalarlo.
- **Accesos directos**: captura de zona, captura de pantalla, portapapeles, paquetes, vista general, fondos.

## Archivos
- `services/Controls.qml` - estado y acciones (singleton). IPC: `qs ipc call control caffeine|night|record|profile|color|dnd|state`.
- `modules/control/ControlCenter.qml` - panel. `modules/bar/ControlButton.qml` - boton.
- hyprland.conf: `bind = $mainMod, C, global, hyprshell:control` y `layerrule` de blur para `hyprshell-control`.

## Probado (3 oct)
Cafeina (aparece/desaparece el inhibidor), perfil de energia (cambia y se restauro), no molestar. Sin probar hasta instalar: luz nocturna, grabacion, selector de color.

## Paquetes (instalados el 3 oct)
`hyprsunset`, `wf-recorder`, `hyprpicker`, `openvpn`. Probado: luz nocturna (on/off), grabacion (2,5 s, 2,3 MB, aviso al guardar). Selector de color: requiere clic del usuario.
Bluetooth no aplica: el equipo no tiene adaptador.

## Siguiente posible
Que la casilla VPN HTB **conecte** con el `.ovpn` del usuario (falta saber donde lo guarda).

Relacionado: [[Barra superior]], [[Atajos de teclado]], [[Modulos hacker]].
