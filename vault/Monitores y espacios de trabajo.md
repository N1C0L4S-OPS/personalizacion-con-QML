# Monitores y espacios de trabajo

## Monitores
- **Izquierdo (DP-2)** = principal. El raton empieza ahi (`cursor:default_monitor`).
- **Derecho (DP-1)** = secundario.

## Espacios de trabajo
- **1 a 5** fijados al monitor izquierdo.
- **6 a 0** (10) fijados al monitor derecho.

Quedan clavados en Hyprland con reglas `workspace = N, monitor:...`, asi que `Super+6` siempre lleva a la pantalla derecha y `Super+1` a la izquierda.

## En la barra
Cada barra muestra siempre sus 5 espacios fijos, en orden:
- El activo se alarga y muestra su numero (el 10 aparece como **0**).
- Con ventanas = claro, vacio = tenue.
- La rueda del raton recorre solo los 5 espacios de esa pantalla, en ciclo.

Relacionado: [[Barra superior]], [[Atajos de teclado]].
