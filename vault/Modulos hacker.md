# Modulos hacker

Cinco modulos en la barra principal para dar ambiente y agilizar HTB.

## 1. Cronometro de maquina
Junto al objetivo, el tiempo desde que se hizo `settarget` (HH:MM:SS). `settarget` ahora guarda la hora de inicio como tercer campo en `~/.config/target_info`. Servicio `Target.qml`.

## 2. Menu de reverse shells
Icono de terminal. Abre un panel con:
- **LHOST**: IP de `tun0` (verde) o la local si no hay VPN. Clic copia.
- **LPORT** editable (por defecto 4444).
- Plantillas con IP y puerto rellenados: listener nc, bash, sh con mkfifo, python3 y PowerShell. Clic copia el comando entero.

## 3. Detector de listeners
Icono de antena con el numero de puertos en escucha (`ss -tlnpH`). **Se pone verde y pulsa** cuando detecta un handler (nc, socat, pwncat, msfconsole...). El panel lista los puertos y resalta los handlers.

## 4. AnonSurf / Tor
Icono de mascara: `clear` en gris o `tor` en verde. El estado se comprueba solo, sin contrasena. Al pulsar abre una terminal con `sudo anonsurf start/stop` para escribir la contrasena.

## 5. Prompt de hacker
`usuario@host:~` al inicio de la barra principal. El cursor parpadeante se quito (resultaba molesto).

Relacionado: [[Helpers de HTB]], [[Barra superior]].
