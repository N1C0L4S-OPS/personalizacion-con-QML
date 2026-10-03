# Historial del portapapeles

`Super+V` (antes "ventana flotante", que pasa a `Super+Shift+V`).

## Que hace
- Guarda todo lo que copias (**texto e imagenes**, incluidas capturas), hasta **100** elementos, sin duplicados (lo repetido sube arriba).
- **Solo en RAM** (`$XDG_RUNTIME_DIR/hyprshell-clip`, permisos 700/600): nunca toca el disco y **se borra al reiniciar**. Pensado para pentesting: contrasenas, hashes y tokens no quedan escritos en un archivo.
- Ignora lo que los gestores de contrasenas marcan como sensible.
- **Etiquetas automaticas**: IP, IPv6, URL, MD5, SHA1, SHA256, hash (`$6$...`), ruta, correo, JWT, base64, "N lineas".

## Panel
- Buscador (texto y etiquetas; "imagen" filtra imagenes), lista con lo ultimo arriba (texto en monoespaciada, imagenes en miniatura), hace cuanto se copio.
- Abajo, el elemento completo (texto con scroll o la imagen grande).
- `Enter` **pega directamente** en la ventana anterior (terminales: Ctrl+Shift+V; resto: Ctrl+V) · `Shift+Enter` solo copia · `Supr` borra · `Ctrl+Supr` vacia todo · clic pega · clic central borra · `Esc` cierra.

## Archivos
- `~/.local/bin/hyprshell-clip` - `store` (lo llama `wl-paste --watch`), `copy ID`, `delete ID`, `clear`.
- `~/.config/quickshell/modules/clipboard/Clipboard.qml` - el panel (lee `index.json` y se actualiza solo).
- hyprland.conf: `exec-once = wl-paste --watch ~/.local/bin/hyprshell-clip store` y los binds.

## Probado
- Guardado de texto, IP, MD5 e imagen; sin duplicados; etiquetas correctas.
- Pegado automatico en kitty con `sendshortcut CTRL SHIFT, V, activewindow`.
- Error encontrado: comprobar si el servicio corria con `pgrep -f` se encontraba a si mismo (regla ya apuntada). Se usa `pgrep -x wl-paste` + linea de comandos.

Relacionado: [[Atajos de teclado]], [[Helpers de HTB]].
