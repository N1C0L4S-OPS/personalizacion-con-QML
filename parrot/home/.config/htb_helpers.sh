# ==============================================================================
# HTB & PENTESTING WORKFLOW HELPERS - PARROT SECURITY ELEGANT EDITION
# ==============================================================================

# Ensure ~/.local/bin is in PATH
export PATH="$HOME/.local/bin:$HOME/.fzf/bin:$PATH"

# Integracion de fzf (Ctrl+R historial, Ctrl+T archivos) segun la shell
if [ -n "$ZSH_VERSION" ]; then
    command -v fzf &> /dev/null && source <(fzf --zsh)
else
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
fi

# Target file path
TARGET_FILE="$HOME/.config/target_info"

# Load target from file on new shell startup
if [ -f "$TARGET_FILE" ]; then
    export TARGET_IP=$(cat "$TARGET_FILE" | awk '{print $1}')
    export TARGET_NAME=$(cat "$TARGET_FILE" | awk '{print $2}')
fi

# Function: settarget <IP> [Name]
settarget() {
    if [ -z "$1" ]; then
        echo -e "\033[1;31m[!] Uso: settarget <IP> [Nombre_Maquina]\033[0m"
        return 1
    fi
    export TARGET_IP="$1"
    export TARGET_NAME="${2:-Target}"
    # Tercer campo: marca de tiempo de inicio (para el cronometro de la barra)
    echo "$TARGET_IP $TARGET_NAME $(date +%s)" > "$TARGET_FILE"
    echo -e "\033[1;32m[+] Objetivo fijado:\033[0m \033[1;36m$TARGET_IP\033[0m ($TARGET_NAME)"
}

# Function: cleartarget
cleartarget() {
    unset TARGET_IP
    unset TARGET_NAME
    rm -f "$TARGET_FILE"
    echo -e "\033[1;33m[*] Objetivo eliminado\033[0m"
}

# Function: mktarget [Name]
mktarget() {
    local folder_name="${1:-$TARGET_NAME}"
    if [ -z "$folder_name" ]; then
        folder_name="HTB_Target"
    fi
    mkdir -p "$folder_name"/{nmap,exploits,content,loot,scripts}
    touch "$folder_name/notes.md"
    echo "# HTB Machine: $folder_name" > "$folder_name/notes.md"
    echo "IP: ${TARGET_IP:-'N/A'}" >> "$folder_name/notes.md"
    echo "Date: $(date)" >> "$folder_name/notes.md"
    cd "$folder_name" || return
    echo -e "\033[1;32m[+] Estructura creada y dentro de:\033[0m \033[1;36m$folder_name/\033[0m"
    eza --icons=always --tree --level=2 2>/dev/null || ls -la
}

# Function: pingtarget
pingtarget() {
    if [ -z "$TARGET_IP" ]; then
        echo -e "\033[1;31m[!] No hay ningún objetivo fijado. Usa settarget <IP>\033[0m"
        return 1
    fi
    echo -e "\033[1;34m[*] Enviando pings a $TARGET_IP ($TARGET_NAME)...\033[0m"
    ping -c 4 "$TARGET_IP"
}

# Function: extractports <nmap_allports.gnmap>
extractports() {
    if [ -z "$1" ]; then
        echo -e "\033[1;31m[!] Uso: extractports <archivo_nmap.gnmap>\033[0m"
        return 1
    fi
    if [ ! -f "$1" ]; then
        echo -e "\033[1;31m[!] Archivo no encontrado: $1\033[0m"
        return 1
    fi
    local ports=$(grep -oP '\d{1,5}/open' "$1" | awk -F'/' '{print $1}' | xargs | tr ' ' ',')
    local ip_address=$(grep -oP 'Host: \K[0-9.]+' "$1" | head -n 1)
    echo -e "\033[1;32m[+] Puertos abiertos extraídos:\033[0m \033[1;33m$ports\033[0m"
    if [ -n "$ip_address" ]; then
        echo -e "\033[1;32m[+] IP:\033[0m \033[1;36m$ip_address\033[0m"
    fi
    if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy &> /dev/null; then
        echo -n "$ports" | wl-copy && echo -e "\033[1;34m[*] Puertos copiados al portapapeles\033[0m"
    elif command -v xclip &> /dev/null; then
        echo -n "$ports" | xclip -selection clipboard && echo -e "\033[1;34m[*] Puertos copiados al portapapeles\033[0m"
    fi
}

# Function: vpnstatus
vpnstatus() {
    local tun_ip=$(ip addr show tun0 2>/dev/null | grep -oP 'inet \K[0-9.]+')
    if [ -n "$tun_ip" ]; then
        echo -e "\033[1;32m[+] VPN HTB Conectada (tun0):\033[0m \033[1;36m$tun_ip\033[0m"
    else
        echo -e "\033[1;31m[-] VPN HTB Desconectada\033[0m"
    fi
}

# Aliases con Eza, Bat y FZF
if command -v eza &> /dev/null; then
    alias ls='eza --icons=always --group-directories-first'
    alias ll='eza -l --icons=always --git --group-directories-first'
    alias la='eza -la --icons=always --git --group-directories-first'
    alias tree='eza --tree --icons=always'
fi

if command -v bat &> /dev/null; then
    alias cat='bat --paging=never --style=plain'
    alias catn='bat --paging=never'
fi

# FZF default options
# fzf y bat con los colores ANSI de kitty (paleta del fondo, generada por themegen)
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border=rounded --info=inline-right --prompt='❯ ' --pointer='▌' --marker='┃' --separator='─' \
  --color=fg:7,fg+:15,bg:-1,bg+:0,hl:6,hl+:14,info:8,prompt:6,pointer:6,marker:2,spinner:6,header:8,border:8,gutter:-1"
export BAT_THEME=ansi

# Starship: en bash se inicia aqui; en zsh lo inicia ~/.zshrc (con el prompt transitorio)
if [ -n "$BASH_VERSION" ] && command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi
