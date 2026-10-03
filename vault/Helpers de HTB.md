# Helpers de HTB

En `~/.config/htb_helpers.sh`, cargado por bash/zsh.

## Funciones
- `settarget <IP> [Nombre]` - fija el objetivo (ahora guarda tambien la hora de inicio, para el [[Modulos hacker|cronometro]]).
- `cleartarget` - borra el objetivo.
- `mktarget [Nombre]` - crea la estructura de carpetas de la maquina (nmap, exploits, content, loot, scripts, notes.md).
- `pingtarget` - ping al objetivo.
- `extractports <scan.gnmap>` - extrae los puertos abiertos y los copia (con `wl-copy`).
- `vpnstatus` - IP de la VPN (tun0).

## Herramientas
- Alias con **eza** (ls/ll/la/tree) y **bat** (cat).
- **fzf** con `Ctrl+R` para el historial.
- Prompt con **Starship** y banner con **Fastfetch** al abrir la terminal.

Relacionado: [[Modulos hacker]], [[Limpieza inicial]].
