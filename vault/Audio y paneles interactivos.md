# Audio y paneles interactivos

## Audio (barra principal)
- Control de **volumen** y de **microfono**, uno al lado del otro. Rueda ajusta, clic silencia.
- Microfono silenciado en rojo.
- **Limite 150%** (salida y micro), con la rueda y con las teclas multimedia (`pamixer --allow-boost --set-limit 150`). Por encima de 100% el valor se pone amarillo; la pastilla marca el 100%.
- Se anadio la tecla de silenciar microfono.

> No se quito el limite del todo: por encima de 150% el audio distorsiona y puede danar equipo y oidos. Es cambiar `maxVolume` en `Theme.qml` si se quiere mas.

## Paneles interactivos (barra secundaria)
Cada dato de la telemetria abre un desplegable en vivo:
- **Red**: grafica de bajada/subida, IP local, puerta de enlace, MAC, IP de VPN, y boton para consultar la **IP publica** (bajo demanda). Cada dato se copia al pulsarlo.
- **CPU**: modelo, grafica de uso, temperatura, carga, top 5 de procesos y boton para abrir btop.
- **GPU**: nombre exacto (AMD Radeon RX 7600), grafica, temperatura, VRAM.
- **Memoria**: RAM, swap y top 5 por memoria.
- **Disco**: cada particion con su barra y boton al gestor de archivos.
- **Encendido**: usuario@host, kernel, version de Hyprland, hora de arranque.
- **Reproductor** (centro): caratula, titulo, artista y controles anterior/pausa/siguiente.

Relacionado: [[Barra superior]], [[Fase 3 - Notificaciones y volumen]].
