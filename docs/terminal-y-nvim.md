# Terminal y Neovim

## kitty (`parrot/home/.config/kitty/kitty.conf`)
JetBrainsMono Nerd Font 11.5, opacidad 0.82 (× la de Hyprland), padding 12×16, sin decoraciones, **estela del cursor** (`cursor_trail 3`), parpadeo suave, pestañas redondeadas solo con 2 o más, `include ~/.cache/hyprshell/kitty-colors.conf` (paleta), `shell /usr/bin/zsh` (zsh solo en kitty; la shell del sistema sigue siendo bash), `map ctrl+shift+f no_op` (para que llegue a Neovim).

## zsh (`parrot/home/.zshrc`)
Sin oh-my-zsh (en Arch usa oh-my-zsh: **pregúntale** si quiere conservarlo; este `.zshrc` es más ligero).
- **Prompt transitorio**: la línea activa muestra el prompt completo; al ejecutar queda `❯ comando` (función `_transient_line_init` con `zle .recursive-edit`; ver el archivo).
- `zsh-syntax-highlighting` (comando válido en acento, inexistente en rojo, colores ANSI = paleta), `zsh-autosuggestions` (gris, `→` acepta), `setopt correct` con mensaje en español, autocompletado con menú sin distinguir mayúsculas, `Ctrl+R` fzf, Ctrl+flechas por palabras.
- Agente SSH: `SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/openssh_agent` (systemd `ssh-agent.socket`; en Arch comprueba la ruta con `systemctl --user show ssh-agent.socket -p Listen`).
- `[Q]` en Arch: `source ~/.config/htb_helpers.sh`; mueve sus alias (eza, bat), `FZF_DEFAULT_OPTS` (colores ANSI) y `BAT_THEME=ansi` al `.zshrc`.
- **En Arch (comprobado)**: zsh ya es su shell de sesión y usa **oh-my-zsh** con `plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)` (plugins en `~/.oh-my-zsh/custom/plugins`, no en `/usr/share`). Opciones: (a) conservar oh-my-zsh y añadir solo el prompt transitorio, Starship y los colores del resaltado; (b) pasar a este `.zshrc` ligero instalando `zsh-autosuggestions` y `zsh-syntax-highlighting` de `extra` (rutas `/usr/share/zsh/plugins/...`). **Pregúntale.** Ojo: el prompt transitorio redefine `zle-line-init`; carga `zsh-syntax-highlighting` **después** (como en el `.zshrc` de Parrot).

## Starship (`parrot/home/.config/starship.toml`)
Dos líneas, icono de la distro (en Arch U+F303), carpeta en acento, git en acento 2, `sudo` en caché (llave amarilla), duración > 2 s, código de error, `❯` rojo si falla; usuario@host solo root/SSH; sin reloj (el usuario lo quitó). Colores por nombre ANSI. `[Q]` `env_var.TARGET_*`.

## Fastfetch (`parrot/home/.config/fastfetch/config.jsonc`)
Logo como **imagen** en kitty (`kitty-direct`) generada por themegen al **tamaño exacto en píxeles** (33×15 celdas de 9×21 px = 297×315) para que no se vea borroso; bloques sistema · hardware (barras alineadas) · HTB. En Arch: logo de Arch teñido, `[Q]` bloque HTB, quizá bloque "uso diario" (actualizaciones pendientes, próximo evento) si él quiere.

## Neovim tipo VSCode (`parrot/home/.config/nvim/`)
lazy.nvim, ~45 plugins: neo-tree (`Ctrl+B`), bufferline, lualine en español, navic (migas), telescope (`Ctrl+P`, `F1` comandos, `Ctrl+F`, `Ctrl+Shift+F`), spectre (`Ctrl+H`), nvim-cmp + LuaSnip + snippets VSCode + texto fantasma, Mason + LSP (pyright, ruff, bashls, lua_ls, ts_ls, html, cssls, jsonls, clangd, marksman, yamlls), conform (`Shift+Alt+F`), trouble, gitsigns, toggleterm (`` Ctrl+` ``/`Ctrl+T`), code_runner (`F5`), vim-visual-multi (`Ctrl+D`), noice, which-key, alpha (bienvenida), persistence. Atajos VSCode completos en `lua/config/keymaps.lua`. **Tema desde la paleta en vivo** (`lua/config/theme.lua`: mini.base16 + vigila `colors.json`), fondo transparente.

**En Arch (Neovim 0.12)** — quita los pins que se pusieron por la 0.10 de Parrot:
- `gitsigns` (`version = "*"`), `mason` / `mason-lspconfig` / `nvim-lspconfig` (`version = "^1"`), `nvim-treesitter` (`branch = "master"`), `conform` (`^7`): usa las versiones actuales. **Ojo**: mason-lspconfig 2.x y nvim-lspconfig nuevo usan `vim.lsp.config()`/`vim.lsp.enable()` en vez de `require('lspconfig').x.setup()` y quitan `setup_handlers`; reescribe `lua/plugins/code.lua` con la API nueva. nvim-treesitter `main` cambia la configuración (ya no `nvim-treesitter.configs`).
- `vim.diagnostic.jump` ya existe (el envoltorio de compatibilidad sigue funcionando).
- obsidian.nvim (se quitó en Parrot por incompatibilidad con 0.10) **se puede volver a añadir** si él lo quiere (tiene Obsidian en Arch).
- Dependencias: `ripgrep`, `fd`, `npm`, `gcc`, `make`, `unzip`.
- Verificación usada: abrir `.py .sh .lua .md .js .c .html .css .json .yaml` en `nvim --headless` y comprobar `vim.lsp.get_clients` y `:messages` vacíos.
