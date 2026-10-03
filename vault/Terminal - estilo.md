# Terminal - estilo

Todo el estilo de la terminal sigue **la paleta del fondo**: se usan los colores ANSI de kitty, que themegen genera (`cyan` = acento, `bright-cyan` = acento 2, `bright-black` = tenue, `red/green/yellow` = estados). Al cambiar el fondo con `Super+W` cambia la terminal entera.

## Prompt (Starship, `~/.config/starship.toml`)
```
╭─  󰉋 …/repo 󰘬 main !  󰓾 SecNotes 10.10.11.230 󰌋 󱎫 4s ✘ 127
╰─❯
```
Modulos activos (Starship no usa plugins, usa modulos):
- Icono de Parrot (glifo `linux-parrot` de Nerd Font).
- `directory` (ruta, candado si es de solo lectura), `git_branch` / `git_state` / `git_status`.
- `python` (solo con entorno virtual activo), `jobs` (procesos en segundo plano).
- `env_var` TARGET_NAME / TARGET_IP: objetivo HTB de `settarget`.
- `sudo`: icono amarillo si sudo tiene la contrasena en cache.
- `cmd_duration` (si tardo mas de 2 s), `status` (codigo de error en rojo; 127 = comando no encontrado).
- `username`/`hostname` solo como root o por SSH. `❯` rojo si el ultimo comando fallo.
- Sin reloj (quitado a peticion del usuario).

## zsh (solo en kitty, `~/.zshrc`)
kitty abre **zsh** (`shell /usr/bin/zsh` en kitty.conf); la shell del sistema sigue siendo bash (TTY, scripts).
- **Prompt transitorio**: el prompt completo solo en la linea activa; al ejecutar queda `❯ comando`.
- **Resaltado** (zsh-syntax-highlighting): comando valido en acento, inexistente/mal escrito en **rojo** antes de pulsar Enter.
- **Sugerencias** en gris del historial (zsh-autosuggestions), aceptar con `→` o `Fin`.
- **Correccion**: "¿Quisiste decir git en vez de agit?" [s/n/a/e].
- Autocompletado con menu, sin distinguir mayusculas; `Ctrl+R` historial con fzf; `Ctrl+←/→` por palabras.
- Historial de bash importado una vez a `~/.zsh_history`.
- `htb_helpers.sh` detecta la shell (fzf y starship en bash o zsh).
- Volver a bash: quitar la linea `shell /usr/bin/zsh` de kitty.conf.

## Banner (Fastfetch, `~/.config/fastfetch/config.jsonc`)
- **Loro de Parrot con las alas abiertas** (del emblema oficial `emblem-parrot.svg`) como imagen en kitty, con degradado diagonal acento -> acento 2. Mascara en `~/.local/share/hyprshell/parrot-wings-mask.png` (y su SVG); themegen la tine en `~/.cache/hyprshell/parrot.png` al **tamano exacto** que ocupa (33x15 celdas de 9x21 px = 297x315) para que kitty no la escale y se vea nitida.
- Bloques: sistema · hardware (memoria y disco con barra) · **HTB** (IP de la VPN tun0 en verde o "desconectado", objetivo actual).

## kitty
- Estela suave del cursor (`cursor_trail`), parpadeo con suavizado.
- Pestanas redondeadas que solo aparecen con 2 o mas.
- Margen interior 12x16, sin decoraciones.

## fzf y bat
- `FZF_DEFAULT_OPTS` con colores ANSI, borde redondeado, `❯` y `▌` (en `htb_helpers.sh`).
- `BAT_THEME=ansi`.

Copias previas de todo en la carpeta de backups. Relacionado: [[Helpers de HTB]], [[themegen - paleta desde el fondo]].
