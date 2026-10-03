# Apps con la paleta

Las aplicaciones (GTK y Qt/KDE) toman los colores del fondo, **excepto los navegadores** (decision del usuario). Solo en la sesion de Hyprland: la de Plasma no cambia.

## Como funciona
`~/.local/bin/themegen-apps` (lo lanza themegen en segundo plano al cambiar de fondo, ~0,6 s; tambien se puede ejecutar a mano):
- **GTK3** -> `~/.themes/hyprshell/`: ARK-Dark (Arc) **recoloreado en OKLCH** - css y 169 imagenes (casillas, interruptores...):
  - grises azulados de Arc -> tonos oscuros del fondo (conservando el orden de claridad);
  - azul de acento `#5294e2` y familia -> acento de la paleta;
  - rojos -> rojo de la paleta, naranjas -> amarillo, verdes -> verde (siguen indicando error/aviso/ok).
- **Iconos** -> `~/.local/share/icons/Hyprshell/`: hereda Flat-Remix-Green-Dark; las carpetas (places) recoloreadas del verde al acento.
- **Qt / KDE** -> `~/.config/qt6ct/colors/hyprshell.conf` (paleta) + `~/.config/qt6ct/qt6ct.conf` (estilo Breeze, iconos Hyprshell, Inter / JetBrainsMono).

## Activacion (hyprland.conf)
```
env = GTK_THEME,hyprshell
env = QT_QPA_PLATFORMTHEME,qt6ct
```
Afecta a las apps abiertas desde Hyprland (atajos, lanzador, terminal). Las apps ya abiertas se actualizan al reabrirlas. Al volver a iniciar sesion aplica a todo.

## Navegadores excluidos
Copias en `~/.local/share/applications/` de `brave-browser`, `firefox-esr` y `firefox-selector` con
`Exec=env GTK_THEME=ARK-Dark QT_QPA_PLATFORMTHEME= ...` -> conservan su tema de siempre.

## Probado
- Meld (GTK): fondos y botones con los tonos del fondo.
- Dolphin (Qt/KDE): panel, seleccion en el acento, carpetas recoloreadas.

## No cubierto
- Apps GTK4/libadwaita (pocas: Cheese, Seahorse): siguen con Adwaita.
- Apps Java (Burp Suite): usan su propio tema.

Relacionado: [[themegen - paleta desde el fondo]], [[Valores y ajustes exactos]].
