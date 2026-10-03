# Lecciones (lo que ya costó tiempo)

Cada una pasó de verdad en Parrot. Detalle histórico en `vault/Errores y correcciones.md`.

## Sistema
1. **LightDM + Hyprland = entrada muerta intermitente.** LightDM (slick-greeter/Xorg) y Hyprland se peleaban por la terminal virtual y los dispositivos. Arreglos que NO sirvieron: cursor por software, quitar layouts, seatd, variables `WLR_*` (Hyprland usa aquamarine, no wlroots). Arreglo real: **SDDM**.
2. **Actualizaciones de la distro reponen el tema de Plymouth** (Parrot reescribió `plymouthd.conf` a `parrot6` en un `full-upgrade`). Protégelo con un hook del gestor de paquetes que solo actúe si el tema cambió.
3. **Comprobaciones con `grep -q` en tuberías largas** (`lsinitramfs | grep -q`) cortan el listado y dan falsos errores ("zstd failed"). Lista a un archivo y busca ahí.
4. **apt (y quizá pacman) no aceptan comillas anidadas en la config de hooks**: mete la lógica en un script y llama al script.
5. **Espejos caídos** dan cientos de "Tried to start delayed item": no es el sistema; reintentar más tarde. Instalar lo pequeño primero.

## Shell / QML
6. **`pkill -f` / `pgrep -f` se encuentran a sí mismos.** `pgrep -x nombre` + revisar `/proc/PID/cmdline`.
7. **Caché de `Loader`**: tras editar QML cargado por Loader (desplegables), reinicia `qs`.
8. **Qt sintetiza movimientos de ratón cuando el contenido se mueve bajo un cursor quieto** → la selección por hover salta. Solo cuenta si cambia `mapToItem(null, x, y)`; y no uses `highlightRangeMode` mientras se navega con ratón (bucle selección → desplazamiento → otra fila bajo el cursor).
9. **`Repeater` con `ListModel` para animar altas/bajas** (barras de contraseña, letras del usuario): marca como "muerto", anima y elimina después; con un modelo entero se rehacen todos los delegados.
10. **`IpcHandler` y nombres**: una función IPC con el mismo nombre que un `id` (p. ej. `search`) lo tapa. Usa nombres distintos (`query`).
11. **`ScreencopyView` de una ventana**: `captureSource: hyprlandToplevel.wayland`; `Hyprland.toplevels` se rellena de forma **asíncrona** tras `refreshToplevels()`.
12. **`roleNames()` no existe en los modelos de SDDM**: lee `userModel`/`sessionModel` con un `Instantiator` y `required property`.
13. **Ventanas de tamaño fijo no van en mosaico** en Hyprland; la regla `tile on` sí funciona con ventanas redimensionables (pruébalo con una ventana hija transitoria).
14. **`kitty --class X` + regla `size`**: `remember_window_size` la pisa; pasa `-o remember_window_size=no`.
15. **Captura de paneles**: abren en el monitor con foco; localiza la capa con `hyprctl layers -j`.
16. **Blur de capas**: `layerrule = match:namespace <ns>, blur on, ignore_alpha <a>`; sin `ignore_alpha` se difumina también el velo transparente.

## Herramientas
17. **Glifos Nerd Font U+E000–F8FF se pierden en heredocs** de algunas herramientas (los de U+F0000+ no). Escribe `""` desde Python y verifica con `od -c`.
18. **Plugins de Neovim que exigen 0.11** (`vim.validate(name, value, validator)` nuevo): gitsigns de desarrollo y obsidian.nvim ≥ 3.16.8. En Arch con 0.12 no aplica, pero recuerda el síntoma: `opt: expected table, got string`.
19. **LSP de servidores no instalados** generan avisos al abrir cada archivo: configura solo los instalados (`setup_handlers` en mason-lspconfig v1; en v2 `automatic_enable`).
20. **Fastfetch + kitty-direct borroso**: genera la imagen al tamaño exacto en píxeles de la caja (celdas × px por celda).
21. **Paleta**: no limites el croma ni inventes tonos: el usuario lo nota ("se inventa los colores").
22. **El usuario no puede ver tu terminal**: cuando necesites su contraseña, ábrele una ventana; cuando le des comandos, uno por bloque.
