# Resumen del proyecto

## Contexto
El escritorio venia de un trabajo previo hecho con **Antigravity**, que habia dejado configuraciones desordenadas y varios fallos. Se decidio continuar de forma quirurgica: cada cambio con copia de seguridad y verificado antes de darlo por bueno.

## Reparto de la personalizacion
- 80% hacking ofensivo, 20% defensivo, algo de forense.
- Prioridad: la estetica (hacker elegante, minimalista, sofisticado).
- Regla fija: **sin emojis**, solo iconos de Nerd Font.
- La paleta de colores se genera **desde el fondo de pantalla**, para que todo quede uniforme.

## Decision clave
En lugar de usar waybar + rofi + swaync por separado, se construyo una **shell propia con Quickshell** (misma tecnologia que Caelestia, en QML), para tener animaciones, coherencia visual y modulos de HTB a medida. Ver [[Arquitectura de la shell]].

## Estado
- Base estable: entrada de teclado/raton arreglada, sistema limpio. Ver [[Arreglo - entrada muerta (LightDM a SDDM)]] y [[Limpieza inicial]].
- Shell funcionando: barra, fondo, lanzador, selector de fondos, menu de energia, notificaciones, avisos de volumen/microfono, paneles interactivos y modulos hacker.
- Pendiente: bloqueo de pantalla e inactividad, login de SDDM, temas GTK/Qt, zsh, Neovim. Ver [[Pendiente - hoja de ruta]].
