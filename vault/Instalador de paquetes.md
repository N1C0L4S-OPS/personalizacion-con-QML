# Instalador de paquetes

Panel de la shell al estilo de Omarchy. **`Super+I`**.

## Flujo
1. **Fuentes compatibles** (solo las que existen en el sistema): tarjetas con logo, n.º de paquetes, instalados y si pide contrasena.
   - **APT** (logo Parrot) - repositorios de Parrot, ~72 200 paquetes, pide contrasena.
   - **Flatpak** (logo Flathub) - ~3 350 apps de escritorio, sin contrasena (se instala en el usuario).
   - `←/→` o raton para elegir, `Enter` o `1`/`2` para abrir.
2. **Buscador**: filtra al escribir (nombre exacto > empieza por > palabra > contiene > descripcion). Hasta 300 resultados.
   - Cada fila: icono (✓ si instalado), nombre, descripcion corta, version (Flatpak), etiqueta "instalado".
   - **Abajo, la ficha del seleccionado**: icono real (Flatpak), nombre, version, resumen, tamano, seccion, desarrollador, web y descripcion.
3. `Enter` instala · `Supr` desinstala (si esta instalado) · `Tab` solo instalados · doble clic tambien · `Esc` vuelve / cierra.
4. La instalacion abre una **terminal pequena flotante** (APT pide la contrasena ahi); al terminar avisa con una **notificacion** y se cierra sola (si falla, espera Enter).

## Archivos
- `~/.local/bin/hyprshell-pkg` - motor (Python): `sources`, `list apt|flatpak`, `info`, `run install|remove`.
  - APT: `apt-cache search .` + `dpkg-query` (instalados) + `apt-cache show` (ficha).
  - Flatpak: catalogo **appstream** de Flathub (`~/.local/share/flatpak/appstream/flathub/...`), cacheado en `~/.cache/hyprshell/pkg/flathub.json` (se rehace si el catalogo cambia).
- `~/.config/quickshell/modules/packages/Packages.qml` - el panel.
- hyprland.conf: `bind = $mainMod, I, global, hyprshell:packages` y regla `hyprshell-pkg` flotante 860x460 centrada.
- IPC: `qs ipc call packages open flatpak` · `qs ipc call packages query steam`.

## Notas
- El panel abre en el monitor con el foco.
- La seleccion solo sigue al raton cuando este se mueve (si la lista cambia bajo un cursor quieto, no salta).
- Probado: fuentes, busqueda en Flatpak ("steam") y APT ("nmap", con ficha completa e "instalado"). La instalacion real queda para la primera vez que el usuario la use.
- Ampliable a pip/npm/cargo/gem (su busqueda es por red).

Relacionado: [[Arquitectura de la shell]], [[Atajos de teclado]].
