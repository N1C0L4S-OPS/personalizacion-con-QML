# Fase 2 - Lanzador, fondos y energia

Tres paneles en QML, con la misma animacion de entrada, desenfoque y la paleta del fondo. Solo uno abierto a la vez.

## Lanzador de aplicaciones (`Super+R`)
- Busqueda difusa por nombre, descripcion y palabras clave.
- Flechas o Tab para moverse, Enter abre, Esc cierra, clic fuera tambien.
- Las ~315 herramientas CLI de Parrot (icono `xterm`) muestran un glifo de terminal sobrio en vez del cuadro con X roja.

## Selector de fondos (`Super+W`)
- Carrusel de los 64 fondos con miniaturas (generadas por `themegen --thumbs`).
- El seleccionado se amplia; el aplicado lleva un punto de acento.
- Enter lo aplica y **recolorea todo el sistema**.

## Menu de energia (`Super+Shift+E` o boton de la barra)
- Bloquear, salir, suspender, reiniciar, apagar.
- Reiniciar y apagar en rojo.

Relacionado: [[Arquitectura de la shell]], [[themegen - paleta desde el fondo]].
