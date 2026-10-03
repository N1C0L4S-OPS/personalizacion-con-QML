# Cambios exactos en hyprland.conf

Todo lo editado en `~/.config/hypr/hyprland.conf`, con copias previas a cada fase (ver [[Copias de seguridad y rutas]]).

## Monitores
```
monitor = DP-2, 1920x1080@60, 0x0, 1
monitor = DP-1, 1920x1080@75, 1920x0, 1
```

## Espacios de trabajo (anadido)
```
workspace = 1..5, monitor:DP-2   (1 con default:true)
workspace = 6..10, monitor:DP-1  (6 con default:true)
```

## Cursor
```
cursor { no_hardware_cursors = 2 ; ... ; default_monitor = DP-2 }
```

## Autostart (exec-once)
- Anadidos: `~/.config/hypr/scripts/persist-log.sh`, `/usr/libexec/hyprpolkitagent &`, `qs &`.
- Quitados: `waybar &`, `swaync &`, `hyprpaper &` (los reemplaza la shell).
- Se conservan: `hypridle &`, dbus/systemctl import environment.

## Variables de entorno quitadas (inutiles en 0.55)
`WLR_NO_HARDWARE_CURSORS`, `WLR_RENDERER_ALLOW_SOFTWARE`, `LIBINPUT_DEFAULT_KEYBOARD_LAYOUT`.

## Colores (anadido)
```
source = ~/.cache/hyprshell/hyprland-colors.conf
```
Viene despues del bloque `decoration`, asi que los colores de borde los marca themegen (las lineas Catppuccin de arriba quedan sobrescritas).

## Transparencia y blur (2 oct, 20:36)
- active/inactive_opacity 0.92/0.85 -> 0.88/0.80.
- blur 8x3 -> 6x2, mas brightness 0.80, contrast 0.90, vibrancy 0.20, noise 0.015.
- Copia previa: `hyprland.conf.bak-*-transparencia` en la carpeta de copias.

## Bloqueo (2 oct)
- `bind = $mainMod, L, exec, loginctl lock-session` (antes `hyprlock`).
- `misc { allow_session_lock_restore = true }`.
- Nuevo `~/.config/hypr/hypridle.conf` (hypridle ya estaba en exec-once pero sin config, no corria).

## Mosaico total (2 oct)
- `windowrule = match:class .*, tile on`: toda ventana nueva entra en mosaico (antes las ventanas hijas/dialogos de apps nacian flotando en (0,0) y se superponian).
- Excepciones que flotan centradas: modales, polkit/pinentry, selectores de archivo (portales), zenity, imagen-en-imagen (fijada).
- Limite de Hyprland: las ventanas de **tamano fijo** (min = max, p. ej. avisos de "Aceptar") no pueden ir en mosaico; quedan flotando.
- Probado: ventana hija redimensionable -> mosaico con la regla, flotante sin ella.

## Capturas
- `Super+Shift+S` / `Print` / `Super+Print` -> `scripts/screenshot.sh zona|pantalla|ventana`.

## Teclado
```
kb_layout = es,us
kb_options = grp:alt_shift_toggle
numlock_by_default = true
```

## Reglas de ventana y de capa
```
windowrule = match:class ^(htb-target)$, float on, size 520 160, center on
windowrule = navegadores (brave, firefox, chromium, chrome, zen...) -> opacity 1.0 override 1.0 override
windowrule = reproductores (mpv, vlc, celluloid) -> opacity 1.0 override 1.0 override
layerrule = blur on, ignore_alpha ... para: hyprshell-bar (0.3),
            overlay / notifications / center / osd / popout (0.5)
```

## Atajos cambiados/anadidos
- `Super+R` -> `global, hyprshell:launcher` (antes rofi).
- `Super+W` -> `global, hyprshell:wallpaper`.
- `Super+Shift+E` -> `global, hyprshell:power`.
- `Super+N` -> `global, hyprshell:notifications` (antes swaync-client).
- Teclas de volumen: `pamixer --allow-boost --set-limit 150` (subir/bajar).
- Anadido `XF86AudioMicMute` -> `pamixer --default-source -t`.
- Base sin cambios: Enter terminal, Q cerrar, E archivos, L hyprlock, Shift+S captura, 1..0 y Shift+1..0.

Relacionado: [[Atajos de teclado]], [[Monitores y espacios de trabajo]], [[Audio y paneles interactivos]].
