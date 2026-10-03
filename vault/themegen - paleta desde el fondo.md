# themegen - paleta desde el fondo

Script en `~/.local/bin/themegen` que genera una paleta sobria a partir del fondo de pantalla.

## Como funciona (version de fidelidad, 2 oct)
- Agrupa los pixeles del fondo en 10 colores reales con **k-means en OKLab** (determinista).
- **Superficies**: tinte del color que mas area ocupa, con intensidad proporcional a su color real (un fondo gris da superficies grises).
- **Acento**: el color real con mas presencia *percibida* (area x croma x luminosidad; los casi negros pesan poco). Se conserva su **tono y croma reales** (hasta 0.16); solo se ajusta la luminosidad (0.70-0.84) para que se lea sobre fondo oscuro.
- **Acento 2**: otro color real del fondo con tono distinto (25 grados o mas). Si el fondo solo tiene un tono, se usa ese mismo con otra luminosidad. **Nunca se inventa un tono.**
- **Fondo gris**: paleta neutra (ya no se usa el teal de GRUB).
- Semanticos (rojo, verde, amarillo...) fijos para conservar su significado, armonizados un 10% con el acento.

### Version anterior (y por que se cambio)
Redondeaba el tono a 10 grados, limitaba el croma a 0.10 con luminosidad fija (lavandas genericas), inventaba el secundario sumando 40 grados, priorizaba manchas pequenas saturadas y ponia teal en fondos grises. Copia en la carpeta de backups (`themegen.bak-*`).

## Salidas (en `~/.cache/hyprshell/`)
- `colors.json` - lo lee la shell (Theme.qml) y recolorea en vivo.
- `hyprland-colors.conf` - bordes de ventana, sombra y color de fondo de Hyprland (el que se ve antes de que cargue la shell).
- `kitty-colors.conf` - colores de la terminal kitty.
- `thumbs/` - miniaturas 480x270 para el selector de fondos.

## Uso
```bash
themegen <imagen>         # aplica la paleta a todo el sistema
themegen --preview <img>  # solo la muestra en la terminal
themegen --thumbs [dir]   # genera miniaturas
```

Desde la shell, al aplicar un fondo con `Super+W`, todo (barra, bordes, kitty) se recolorea a la vez.

Relacionado: [[Arquitectura de la shell]], [[Fase 2 - Lanzador, fondos y energia]].
