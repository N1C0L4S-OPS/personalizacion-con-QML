# Componentes: qué hace cada pieza

Comportamiento tal como quedó en Parrot (probado). En Arch, lo marcado **(HTB)** se quita.

## Barra (`modules/bar/`)
Una barra flotante por monitor, con blur.
- **Principal (DP-2)**: prompt `user@host:~` (HTB), espacios 1-5, título de ventana, **reloj 12 h** al centro (clic: calendario), a la derecha objetivo + cronómetro (HTB), HTB/VPN (HTB), listeners (HTB), reverse shells (HTB), AnonSurf (HTB), volumen y micro (rueda ajusta hasta 150 %, clic silencia, amarillo > 100 %), **centro de control**, notificaciones (clic derecho: no molestar), energía.
- **Secundaria (DP-1)**: espacios 6-0, **espectro de audio** (cava, 20 barras, se pliega en silencio) + reproductor (título limpiado: sin "(Official Video)", "VEVO", "- Topic", artista repetido; nunca invade la telemetría; se desliza al pasar el ratón si está cortado), telemetría interactiva (IP, red, CPU, GPU, RAM, disco, uptime → cada una abre su desplegable).
- Espacios: el activo se alarga con su número (10 = "0"); rueda recorre los del monitor.

## Desplegables (`modules/popouts/`)
Red (gráfica, IP local, gateway, MAC, IP pública bajo demanda; clic copia), CPU (modelo, gráfica, temp, carga, top 5, abrir btop), GPU (nombre por libdrm, gráfica, temp, VRAM), memoria (RAM, swap, top 5), disco (particiones), sistema (usuario, kernel, Hyprland, arranque), reproductor (carátula y controles), **calendario** (hora con segundos, mes navegable con flechas/rueda, hoy resaltado, clic en el mes vuelve a hoy).

## Paneles
- **Lanzador** `Super+R`: búsqueda difusa (nombre > palabra > contiene > metadatos > subsecuencia), ~315 herramientas CLI de Parrot con glifo de terminal.
- **Fondos** `Super+W`: carrusel de miniaturas, Enter aplica y recolorea todo.
- **Energía** `Super+Shift+E`: bloquear, salir, suspender, reiniciar, apagar.
- **Notificaciones** `Super+N`: avisos arriba-derecha (5 s, pausa con ratón, máx. 4, críticos con franja roja y fijos), centro con historial, no molestar.
- **OSD**: pastilla abajo-centro para volumen y micro.

## Bloqueo (`modules/lock/`) — `Super+L` / hypridle
Captura cada monitor y la difumina (~1 s), reloj 12 h grande, **contraseña sin texto**: una barra vertical por carácter en el acento; comprobando = ola; error = temblor rojo y caída; acierto = convergen en una línea de luz y el desenfoque se disuelve al escritorio. Respaldo hyprlock si la shell no corre. Ver `vault/Fase 4 - Pantalla de bloqueo.md`.

## Vista general (`modules/overview/`) — `Super+Tab`
En cada monitor sus 5 espacios como miniaturas: fondo + ventanas **en vivo** (ScreencopyView) en posición real con icono. Clic ventana: ir; clic espacio: cambiar; **arrastrar** ventana a otro espacio: mover; clic central / Supr: cerrar; ←→ Tab Enter 1-5 Esc.

## Portapapeles (`modules/clipboard/` + `~/.local/bin/hyprshell-clip`) — `Super+V`
Texto e imágenes, 100 elementos, sin duplicados, **solo en RAM** (`$XDG_RUNTIME_DIR/hyprshell-clip`, 700/600), ignora contenido marcado sensible. Etiquetas automáticas (IP, URL, MD5/SHA1/SHA256, hash `$6$`, ruta, correo, JWT, base64, N líneas). Enter **pega** en la ventana anterior (`sendshortcut`; Ctrl+Shift+V en terminales), Shift+Enter copia, Supr borra, Ctrl+Supr vacía.

## Centro de control (`modules/control/` + `services/Controls.qml`) — `Super+C`
Cabecera (usuario, uptime, bloquear, energía), deslizadores de volumen y micro (hasta 150 %, marca 100 %), casillas: no molestar, luz nocturna (hyprsunset 4200 K), cafeína (`systemd-inhibit --what=idle`, hypridle lo respeta), perfil de energía (powerprofilesctl), AnonSurf (HTB), VPN HTB (HTB), grabar pantalla (wf-recorder → `~/Videos/Grabaciones`, botón de barra rojo latiendo), selector de color (hyprpicker). Sin herramienta: casilla atenuada "no instalado · paquete". Accesos: capturas, portapapeles, paquetes, vista general, fondos.

## Instalador (`modules/packages/` + `~/.local/bin/hyprshell-pkg`) — `Super+I`
Fuentes compatibles (APT ~72 200, Flatpak ~3 350 desde el appstream de Flathub con iconos) → buscador con ficha abajo (versión, tamaño, sección, desarrollador, web, descripción) → Enter instala / Supr desinstala en terminal flotante con notificación al acabar; Tab solo instalados. En Arch: pacman + AUR + Flatpak + actualizaciones (ver `migracion-arch.md`).

## Capturas (`~/.config/hypr/scripts/screenshot.sh`)
`Super+Shift+S` zona (slurp con colores de la paleta), `Print` monitor, `Super+Print` ventana. Guarda en `~/Pictures/Capturas`, copia como imagen, aviso con miniatura.

## Hyprland
Mosaico total con excepciones flotantes; navegadores y reproductores opacos; opacidad 0.88/0.80; blur 6×2 oscurecido; animaciones sin rebote; color de fondo de Hyprland = `bg` de la paleta (sin flash gris al iniciar sesión).
