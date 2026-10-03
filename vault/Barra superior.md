# Barra superior

Una barra flotante por monitor, con desenfoque detras. Las **dos barras muestran informacion distinta** para no ser redundantes.

## Barra principal (monitor izquierdo, DP-2)
Contexto de trabajo:
- **Prompt** `usuario@host:~` (izquierda), sin cursor.
- Espacios de trabajo 1-5 (ver [[Monitores y espacios de trabajo]]).
- Titulo de la ventana activa.
- **Centro**: reloj en **12 h** (`9:08 pm`) y fecha. **Clic abre el calendario**: hora grande con segundos, fecha completa, mes navegable con flechas o rueda del raton, hoy resaltado con el acento, fines de semana con el acento secundario; clic en el nombre del mes vuelve al actual.
- **Derecha**: objetivo HTB + cronometro, modulo HTB, listeners, reverse shells, AnonSurf, volumen, microfono, notificaciones, energia. Ver [[Modulos hacker]] y [[Audio y paneles interactivos]].

## Barra secundaria (monitor derecho, DP-1)
Telemetria del sistema:
- Espacios de trabajo 6-0.
- **Centro**: **espectro de audio** (cava, 20 barras con degradado acento -> acento2, se pliega tras 1,5 s de silencio) + lo que suena ahora (Mpris) o la fecha larga. El bloque central **nunca pisa la telemetria**: su ancho maximo se calcula con el espacio libre real; si no cabe, el titulo se corta con "..." y **se desliza al pasar el raton**. El titulo se **limpia** (quita "(Official Video)", "VEVO", "- Topic", [HD], (Lyrics) y el artista repetido).
- **Derecha**: IP local, bajada/subida de red, CPU %+temp, GPU %+temp, RAM, disco, tiempo encendido. Cada dato abre un **panel interactivo**. Ver [[Audio y paneles interactivos]].

## Modulo de Hack The Box
Logo oficial de HTB. **Desconectado**: `disconnected` en rojo. **Conectado**: la IP de `tun0` en verde HTB (`#9fef00`). Clic central copia la IP.

Relacionado: [[Arquitectura de la shell]].
