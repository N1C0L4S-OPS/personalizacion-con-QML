# Valores y ajustes exactos

## Paleta y diseno (Theme.qml)
- Tipografia: Inter (sans), JetBrainsMono Nerd Font Propo (mono). Tamanos 13 / 11.
- Radios: 12 (normal), 8 (pequeno). Gap 8. Altura de barra 36.
- Animacion: rapida 160 ms, normal 320 ms, lenta 600 ms. Curva `[0.05, 0.7, 0.1, 1, 1, 1]`.
- Monitor principal: DP-2. Volumen maximo: 1.5 (150%). Verde HTB: `#9fef00`.
- Colores por defecto (hasta que carga el fondo): bg `#0e1111`, surface `#161b1b`, surface2 `#1c2222`, overlay `#2c3434`, fg `#c8d0cc`, fgMuted `#8f9995`, fgDim `#6b7774`, accent `#7fb3ad`, accentDim `#5c8b8b`, accent2 `#9fb8c9`, red `#c87b7b`, yellow `#c9a96e`, green `#8fbf8f`, blue `#7da7c9`, magenta `#b493b8`, cyan `#7fbcc0`.
- Estos colores se sustituyen en vivo por los del fondo (ver [[themegen - paleta desde el fondo]]).

## Hyprland - decoracion
- gaps_in 5, gaps_out 10, border_size 2, rounding 12.
- active_opacity **0.88**, inactive_opacity **0.80** (antes 0.92 / 0.85).
- blur size **6**, passes **2** (antes 8 / 3), ignore_opacity true, brightness 0.80, contrast 0.90, vibrancy 0.20, noise 0.015. El blur es mas suave para que se intuya el fondo, y se oscurece para que el texto siga legible.
- **Navegadores y reproductores siempre opacos** (regla `opacity 1.0 override 1.0 override`): brave (y sus apps web), firefox, librewolf, chromium, chrome, zen, mpv, vlc, celluloid.

## Animaciones de Hyprland (3 oct)
Mismas curvas que la shell, sin rebote (antes `winIn 0.1,1.1,0.1,1.1` y `winOut 0.3,-0.3,0,1` rebotaban):
- `emphasized 0.05,0.7,0.1,1` (= Theme.curve) · `emphasizedAccel 0.3,0,0.8,0.15` · `standard 0.2,0,0,1`.
- windowsIn 4 (popin 90%), windowsOut 2.5 (popin 90%), windowsMove 4, fade 3.2, border 3.2, workspaces 4.5 (slidefade 12%), specialWorkspace 4, layers 2 (fade: la shell anima su contenido).
- Medido: la ventana crece de forma monotona y se asienta en ~290 ms, sin pasarse del tamano final.

## Cursor (3 oct)
- **Bibata-Modern-Classic** 24 px (paquete `bibata-cursor-theme`; antes breeze_cursors).
- Hyprland: `env = XCURSOR_THEME,Bibata-Modern-Classic` + `exec-once = hyprctl setcursor Bibata-Modern-Classic 24`.
- GTK: gsettings `cursor-theme` y `gtk-cursor-theme-name` en gtk-3.0/gtk-4.0 settings.ini. X11: `~/.icons/default/index.theme`.
- Inicio de sesion: `/etc/sddm.conf.d/zz-hyprshell-cursor.conf`.
- Variantes instaladas: Modern/Original x Classic (negro), Ice (blanco), Amber.

## kitty (opacidad)
- background_opacity 0.82, dynamic_background_opacity yes, background_tint 0.35.
- Colores: `include ~/.cache/hyprshell/kitty-colors.conf` (antes Catppuccin fijo).

## Audio
- Limite 150% con rueda y teclas (`pamixer --allow-boost --set-limit 150`).

Relacionado: [[Cambios exactos en hyprland.conf]], [[Inventario de archivos]].
