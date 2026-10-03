# Errores y correcciones

Registro honesto de los fallos cometidos durante el trabajo y como se corrigieron (ninguno dejo dano en el sistema; todos verificados despues).

- **Diagnosticos erroneos de Antigravity**: cursor por software, quitar `es,us`, seatd, variables `WLR_*`. No atacaban la causa real (carrera LightDM/Hyprland). Se revirtieron y se cambio a SDDM.
- **Edicion automatica que rompio 3 archivos de la barra** (Vpn, Volume, HtbTarget): un script de transformacion dejo mal las llaves. Se detecto al revisar y se reescribieron a mano.
- **`SystemClockProxy`**: tipo QML inexistente en Media.qml; corregido a `SystemClock` antes de cargar.
- **`pkill -f` que se mato a si mismo**: el patron coincidia con el propio comando. Se evito despues; apuntado como regla.
- **`cat` sin entrada**: dejo un comando colgado; se detuvo.
- **Capturas en negro**: tomadas mientras la shell cargaba el fondo; se repitieron despues.
- **Nombre de GPU generico**: se cambio a la fuente de libdrm (como fastfetch) -> "AMD Radeon RX 7600".
- **Icono xterm (cuadro con X roja)** en ~315 herramientas CLI: mapeado a un glifo de terminal.
- **QML en cache por Loader**: tras editar un desplegable hay que reiniciar `qs`.
- **Avisos `TypeError ... of null` en Popups.qml** (`expireTimeout`, `transient`): el temporizador de cada aviso leia la notificacion despues de destruirse (durante la animacion de salida). Se protegio con comprobacion de nulo y copia local antes de `hidePopup`. Probado con 5 notificaciones (normales, expiracion corta, cierre externo): 0 errores.
- **`htb-target` salia a pantalla completa**: kitty aplicaba su tamano recordado despues de la regla `size 520 160`. Arreglado con `-o remember_window_size=no` en `HtbTarget.qml`.
- **Prueba de mosaico enganosa**: una ventana de tamano fijo no puede ir en mosaico en Hyprland (ni con `Super+V`); la prueba valida se hizo con una ventana hija redimensionable.
- **Lanzador: la seleccion saltaba al centro** al llegar al borde con las flechas, y daba tirones al pasar el raton. Causa real (medida con una replica de la lista: el ListView solo se desplaza perfecto): **Qt simula "el raton se movio" cada vez que el contenido se desplaza bajo un cursor quieto**, asi la fila bajo el cursor se seleccionaba sola; y con el desplazamiento anticipado, pasar el raton cerca del borde creaba un bucle (seleccion -> desplazamiento -> otra fila bajo el cursor). Arreglo en lanzador, paquetes y portapapeles: solo cuenta el movimiento si cambia la posicion real en pantalla (`mapToItem(null, ...)`), y el desplazamiento anticipado (`ApplyRange`, 56 px) solo se usa con teclado (`mouseSel`).
- **Las imagenes se abrian con Brave**: Gwenview (KDE) ya estaba instalado pero no era el predeterminado. `xdg-mime default org.kde.gwenview.desktop` para png/jpeg/gif/webp/bmp/svg/tiff/ico/avif/heif. Copia de `~/.config/mimeapps.list` en backups.
- **Cursor parpadeante del prompt** quitado de `Prompt.qml` a peticion del usuario (resultaba molesto).

Relacionado: [[Arreglo - entrada muerta (LightDM a SDDM)]].
