# themegen: paleta desde el fondo

`parrot/home/.local/bin/themegen` (Python: numpy + Pillow) y `themegen-apps`.

## Uso
```
themegen <imagen>         aplica la paleta a todo
themegen --preview <img>  solo muestra la paleta en la terminal
themegen --thumbs [dir]   miniaturas 480x270 para el selector (~/.cache/hyprshell/thumbs)
themegen-apps [gtk|icons|qt]   temas de apps (lo lanza themegen en segundo plano)
```

## Algoritmo (versión "fidelidad", la buena)
1. Reduce el fondo a 200 px y pasa los píxeles a **OKLab**.
2. **k-means** determinista (k=10, k-means++ semilla 0) con croma ×1.6 en la distancia (separa colores, no solo luces) → 10 colores reales con su proporción.
3. **Superficies**: tinte del grupo con más área, intensidad proporcional a su croma real (fondo gris → superficies grises).
4. **Acento**: grupo con más presencia percibida = `area^0.5 × croma^1.3 × visibilidad` (los casi negros pesan poco). Conserva **tono y croma reales** (máx. 0.16); solo ajusta la luz a 0.70-0.84 para leerse sobre oscuro.
5. **Acento 2**: otro grupo real con tono ≥ 25° distinto; si no hay, el mismo tono con otra luz. **Nunca inventa tonos.**
6. Semánticos (rojo, amarillo, verde, azul, magenta, cian) fijos y armonizados un 10 % con el acento.
7. Conversión OKLCH → sRGB reduciendo croma hasta entrar en gama.

La versión anterior (descartada) redondeaba el tono a 10°, limitaba el croma a 0.10 con luz fija (lavandas genéricas), inventaba el secundario (+40°) y ponía teal en fondos grises. El usuario notó que "se inventaba los colores".

## Salidas (`~/.cache/hyprshell/`)
`colors.json` (shell, nvim), `hyprland-colors.conf` (bordes, sombra, `misc:background_color`), `kitty-colors.conf` (16 colores ANSI → por eso Starship, fzf, bat y fastfetch usan nombres ANSI y siguen la paleta), `parrot.png` (logo teñido para fastfetch), `thumbs/`.

## Apps (`themegen-apps`)
- **GTK**: copia de ARK-Dark (Arc) **recoloreada en OKLCH** (css + 169 PNG): grises → tonos del fondo, azul `#5294e2` → acento, rojos/naranjas → rojo/amarillo. Resultado en `~/.themes/hyprshell`; se activa con `env = GTK_THEME,hyprshell` solo en Hyprland.
- **Iconos**: Flat-Remix-Green-Dark con carpetas recoloreadas → `~/.local/share/icons/Hyprshell`.
- **Qt**: paleta qt6ct (`~/.config/qt6ct/colors/hyprshell.conf`, 21 roles) + estilo Breeze; `env = QT_QPA_PLATFORMTHEME,qt6ct`.
- **Excluidos**: navegadores (decisión del usuario) vía copias de sus `.desktop` con `GTK_THEME` fijo.
- En Arch la base GTK cambia (no hay ARK-Dark): ver `migracion-arch.md` fase 6 (adw-gtk3 + `@define-color` es probablemente mejor).

## Comprobar fidelidad
`parrot/` no incluye el script de comparación, pero el método fue: hoja con fondo · grupos reales (ancho = área) · paleta antigua · paleta nueva, sobre ~10 fondos variados. Repítelo si tocas el algoritmo.
