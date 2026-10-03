# Fase 4 - Pantalla de bloqueo

Pantalla de bloqueo propia en QML (`~/.config/quickshell/modules/lock/`), minimalista, con el bloqueo de sesion real de Wayland (`WlSessionLock`) y autenticacion PAM (`/etc/pam.d/hyprlock` -> common-auth).

## Como se ve
1. **Al bloquear**: captura cada monitor (grim) y lo **difumina todo** con una animacion de ~1 s (barra, ventanas, fondo), oscureciendo levemente con el tono de la paleta.
2. **Reloj**: aparece despues, grande y fino (Inter ExtraLight 136 px), en **12 h** con am/pm (desde el 3 oct, como la barra y el inicio de sesion), con la fecha en minusculas debajo. Entra deslizandose y cerrando el espaciado de letras.
3. **Contrasena sin caja de texto**: en la base de la pantalla, **una barra vertical por cada caracter**, en el color de acento del fondo, con un leve resplandor. Al escribir crece desde abajo y el grupo se recentra. Un punto que respira indica donde escribir cuando no hay nada.
4. **Comprobando**: las barras laten en ola.
5. **Incorrecta**: tiemblan, se tinen de **rojo** y caen una a una; luego se puede escribir de nuevo.
6. **Correcta**: el reloj se eleva y se desvanece, las barras **convergen en el centro** y nacen en una **linea de luz** que se expande, mientras el desenfoque se disuelve hasta el escritorio real.

## Teclas
- `Enter` comprobar · `Retroceso` borra una barra · `Ctrl+Retroceso` o `Esc` borra todo.

## Archivos
- `modules/lock/Lock.qml` - estado, captura, PAM, `WlSessionLock`, modo prueba e IPC.
- `modules/lock/LockSurface.qml` - desenfoque, velo y reloj de cada monitor.
- `modules/lock/PassBars.qml` - las barras y sus animaciones.
- `~/.config/hypr/hypridle.conf` - nuevo.

## Activacion
- `Super+L`, el boton Bloquear del menu de energia y la inactividad usan `loginctl lock-session` -> hypridle -> `qs ipc call lock lock`.
- **hypridle**: bloquear a los 10 min, apagar monitores a los 20, sin suspension. Bloquea tambien antes de suspender.
- Si `qs` no esta corriendo, hypridle usa **hyprlock** como respaldo.

## Pruebas
```bash
qs ipc call lock preview          # modo prueba, NO bloquea (Esc sale, PAM real)
qs ipc call lock debugType 8      # (solo en prueba) simula 8 caracteres
qs ipc call lock debugResult false  # (solo en prueba) simula error / true = acierto
```

## Seguridad / recuperacion
- `misc:allow_session_lock_restore = true` en hyprland.conf: si la shell se cae con la sesion bloqueada, otro bloqueador puede tomar el relevo.
- Si algun dia queda una pantalla rota: `Ctrl+Alt+F3`, iniciar sesion y ejecutar
  `hyprctl --instance 0 dispatch exec hyprlock`; volver con `Ctrl+Alt+F1` (o F2) y desbloquear con hyprlock.
- Si la captura falla se bloquea igual (fondo liso): la seguridad va primero.

Relacionado: [[Arquitectura de la shell]], [[Atajos de teclado]], [[Pendiente - hoja de ruta]].
