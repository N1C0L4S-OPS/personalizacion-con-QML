# ==============================================================================
#  zsh - Parrot + Hyprland (kitty la usa como shell; la shell del sistema sigue siendo bash)
# ==============================================================================

# ---- Historial ----
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt share_history hist_ignore_all_dups hist_ignore_space hist_reduce_blanks extended_history

# ---- Opciones ----
setopt auto_cd              # escribir una carpeta entra en ella
setopt interactive_comments
setopt correct              # "zsh: correct 'nmpa' to 'nmap'?"  (y/n)
setopt no_beep
SPROMPT='%F{yellow}¿Quisiste decir %F{cyan}%r%F{yellow} en vez de %F{red}%R%F{yellow}?%f [s/n/a/e] '

# ---- Agente SSH ----
[ -S "$XDG_RUNTIME_DIR/openssh_agent" ] && export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/openssh_agent"

# ---- Rutas ----
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

# ---- Autocompletado ----
autoload -Uz compinit && compinit -d ~/.cache/zcompdump
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{8}── %d ──%f'
zstyle ':completion:*' group-name ''

# ---- Teclas (estilo emacs + Ctrl+flechas por palabra) ----
bindkey -e
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^H' backward-kill-word       # Ctrl+Retroceso

# ---- Utilidades de Parrot (venian en .bashrc) ----
hex-encode() { echo "$@" | xxd -p; }
hex-decode() { echo "$@" | xxd -p -r; }
rot13()      { echo "$@" | tr 'A-Za-z' 'N-ZA-Mn-za-m'; }

# ---- Helpers de HTB (settarget, extractports, alias eza/bat, fzf...) ----
[ -f ~/.config/htb_helpers.sh ] && source ~/.config/htb_helpers.sh

# ---- Sugerencias en gris segun el historial (aceptar con flecha derecha o End) ----
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# ---- Prompt: Starship ----
command -v starship &> /dev/null && eval "$(starship init zsh)"

# ---- Prompt transitorio ----
# El prompt completo solo se ve en la linea activa; al ejecutar, esa linea queda como "❯ comando".
_transient_line_init() {
    emulate -L zsh
    [[ $CONTEXT == start ]] || return 0
    while true; do
        zle .recursive-edit
        local -i ret=$?
        [[ $ret == 0 && $KEYS == $'\4' ]] || break   # Ctrl+D en linea vacia
        [[ -o ignore_eof ]] || exit 0
    done
    local saved_prompt=$PROMPT saved_rprompt=$RPROMPT
    PROMPT='%F{cyan}❯%f '
    RPROMPT=''
    zle .reset-prompt
    PROMPT=$saved_prompt
    RPROMPT=$saved_rprompt
    if (( ret )); then
        zle .send-break
    else
        zle .accept-line
    fi
    return ret
}
zle -N zle-line-init _transient_line_init

# ---- Resaltado de comandos (debe ir al final) ----
# Verde/acento = existe · rojo = mal escrito o inexistente
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    typeset -A ZSH_HIGHLIGHT_STYLES
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
    ZSH_HIGHLIGHT_STYLES[command]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[function]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[precommand]='fg=cyan,italic'
    ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=magenta'
    ZSH_HIGHLIGHT_STYLES[path]='fg=15,underline'
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=14'
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=14'
    ZSH_HIGHLIGHT_STYLES[comment]='fg=8,italic'
fi

# ---- Banner ----
[[ $- == *i* ]] && command -v fastfetch &> /dev/null && fastfetch
