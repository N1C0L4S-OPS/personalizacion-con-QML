# Neovim - como VSCode

Configuracion en `~/.config/nvim/` (lazy.nvim, ~45 plugins, todos fijados a versiones compatibles con **nvim 0.10.4**). Colores: la **paleta del fondo**, en vivo (vigila `~/.cache/hyprshell/colors.json`; al cambiar de fondo se recolorea aunque nvim este abierto). Fondo transparente como kitty.

## Estructura
- `init.lua` - arranque y lazy.nvim.
- `lua/config/options.lua` - opciones (raton, portapapeles, Shift+flechas selecciona, deshacer persistente...).
- `lua/config/keymaps.lua` - atajos tipo VSCode.
- `lua/config/theme.lua` - tema desde la paleta (mini.base16) + recarga en vivo.
- `lua/config/autocmds.lua` - resaltar lo copiado, volver a la ultima posicion, `q` cierra ventanas auxiliares...
- `lua/plugins/ui.lua` · `editor.lua` · `code.lua`.

## Atajos (chuleta)
| Atajo | Accion |
|---|---|
| `Ctrl+P` | Abrir archivo (buscador) |
| `F1` | Paleta de comandos |
| `Ctrl+B` | Explorador lateral (git incluido) |
| `Ctrl+F` / `Ctrl+Shift+F` | Buscar en el archivo / en el proyecto |
| `Ctrl+H` | Buscar y reemplazar en el proyecto |
| `Ctrl+S` · `Ctrl+Q` | Guardar · salir |
| `Ctrl+Z` · `Ctrl+Y` · `Ctrl+A` | Deshacer · rehacer · seleccionar todo |
| `Ctrl+C` · `Ctrl+X` · `Ctrl+V` | Copiar · cortar · pegar (sistema) |
| `Ctrl+/` | Comentar linea o seleccion |
| `Ctrl+D` | Multicursor: siguiente coincidencia |
| `Ctrl+Alt+↑/↓` | Anadir cursor arriba/abajo |
| `Alt+↑/↓` · `Shift+Alt+↑/↓` | Mover linea · duplicar linea |
| `Tab` / `Shift+Tab` (seleccion) | Sangrar / quitar sangria |
| `Shift+flechas` | Seleccionar (escribir reemplaza) |
| `Ctrl+W` · `Ctrl+RePag/AvPag` · `Alt+1..9` | Cerrar pestana · cambiar pestana · ir a la pestana N |
| `Ctrl+\` · `Alt+h/j/k/l` | Dividir · moverse entre divisiones |
| `Ctrl+`` ` o `Ctrl+T` | Terminal integrada abajo |
| `F5` | Ejecutar el archivo (python, bash, c, cpp, go, rust, node, lua, php) |
| `F2` · `F12` · `Shift+F12` | Renombrar · ir a definicion · referencias |
| `Ctrl+.` | Acciones rapidas (arreglos) |
| `F8` / `Shift+F8` | Siguiente / anterior problema |
| `Shift+Alt+F` | Formatear |
| `Ctrl+Espacio` | Forzar autocompletado (en normal: seleccion inteligente) |
| `K` | Documentacion del simbolo |
| `Espacio` | Menu con TODO lo demas (which-key) |

`Espacio` + `x` problemas · `g` git (blame, ver/deshacer cambio) · `f` buscar (simbolos, recientes, atajos) · `s` sesiones · `t` terminal flotante/vertical · `u` opciones (numeros relativos, ajuste, historial de cambios).

## Que incluye
- Bienvenida con accesos (nuevo, buscar, recientes, restaurar sesion, boveda, configuracion).
- Pestanas arriba (bufferline), explorador (neo-tree), barra de estado en espanol (lualine), migas de pan del simbolo (navic).
- Autocompletado con documentacion y **texto fantasma** (nvim-cmp + snippets de VSCode).
- LSP (Mason): Python, Bash, Lua, JS/TS, HTML, CSS, JSON, C/C++, Markdown, YAML. Formateadores: ruff, stylua, shfmt, prettier.
- Treesitter (27 lenguajes), autopairs, autotag, colores en el codigo, guias de sangria, TODOs, git en el margen.
- Panel de problemas (trouble), terminal integrada (toggleterm), ejecutar archivo (code_runner), sesiones (persistence), historial de cambios (undotree).
- Linea de comandos centrada tipo paleta (noice).
- No incluidos (requieren cuenta/clave): avante y copilot del init.lua de Arch.

## Requisitos (instalados el 2 oct)
- ripgrep 14.1.1, fd 10.2.0, npm 9.2.0.
- 14 paquetes de Mason: pyright, ruff, bash-language-server, lua-language-server, typescript-language-server, html/css/json/yaml-lsp, clangd, marksman, prettier, stylua, shfmt.
- Verificado: .py (pyright+ruff), .sh, .lua, .md, .js, .c, .html, .css, .json, .yaml conectan su LSP sin avisos.

## Notas tecnicas
- kitty: `map ctrl+shift+f no_op` para que el atajo llegue a nvim.
- gitsigns fijado a version publicada (la de desarrollo exige nvim 0.11).
- `vim.diagnostic.jump` no existe en 0.10: se usa `goto_next/goto_prev`.
- Solo se activan los servidores LSP **instalados** (antes avisaba "pyright no encontrado" al abrir .py).
- **obsidian.nvim quitado**: todas sus versiones recientes usan `vim.validate` de nvim 0.11 (error al abrir .md). Para la boveda, la app de Obsidian.
- Probado: .py .sh .lua .md .js .c abren sin mensajes de error.

## Instalacion de paquetes (2 oct)
El primer `apt install ripgrep fd-find npm` fallo por **espejos de Parrot caidos** (bunny.deb.parrot.sh 502, mirrors.aliyun.com cerro la conexion); no se instalo nada. Reintentar: `sudo apt update && sudo apt install -y ripgrep fd-find` y luego `sudo apt install -y npm`.

Relacionado: [[Terminal - estilo]], [[themegen - paleta desde el fondo]].
