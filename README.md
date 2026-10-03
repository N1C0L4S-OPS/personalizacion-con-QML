# personalizacion-con-QML

Escritorio Hyprland con una **shell propia en QML (Quickshell)** y la **paleta generada desde el fondo de pantalla**.
Se construyó en **Parrot Security** (enfocado a aprender Hack The Box). Este repositorio sirve para **llevarlo al Arch Linux del mismo usuario**, cuyo enfoque es el **uso diario**.

> **Este README está escrito para otro Claude (Opus 5.5) que va a hacer la migración en Arch.**
> Si eres ese Claude: léelo entero antes de tocar nada. Está ordenado como lo harías tú: contexto, estado de partida, principios, plan por fases, trampas conocidas.
> Si eres el usuario: el resumen está en [Para el usuario](#para-el-usuario).

---

## 0. Contexto rápido

| | Parrot (origen) | Arch (destino) |
|---|---|---|
| Propósito | Aprender **Hack The Box** / pentesting | **Uso diario**: juegos (Steam), Discord, Spotify, Zoom, ofimática, programación |
| Disco | `sda` 224 GB, LUKS + btrfs | `sdc` 224 GB (`sdc2` ext4, `sdc1` ESP 1 GB), sin cifrar |
| Hyprland | 0.55.2 | **0.56.2** |
| Qt / Neovim | 6.8 / 0.10.4 | **6.11 / 0.12.5** |
| Monitores | 2: `DP-2` izq (principal, 60 Hz) y `DP-1` der (75 Hz) | **3**: `HDMI-A-1` arriba (0x0), `DP-2` abajo-izq (920x1080), `DP-1` abajo-der (2840x1080) |
| Teclado | `es,us` (Alt+Shift) | **`latam`** |
| Login | SDDM (tema propio QML) | **LightDM** activo (¡ver trampa nº 1!), SDDM y greetd/regreet instalados |
| Arranque | GRUB de Parrot + Plymouth propio | **El GRUB de Arch es el principal de la máquina** (arranca Arch, Parrot y Windows) |
| Personalización | Shell QML completa (este repo) | Waybar + Rofi + Dunst + matugen/wallust/pywal + awww + scripts "estilo Omarchy" |

Hardware común: Ryzen 5 5600G + **Radeon RX 7600** (Mesa, sin NVIDIA).

El usuario describe su Arch actual como *"una capa de pintura sin accesorios"*: se ve bien pero no tiene las funciones de esta shell. El objetivo es que el Arch quede **muy parecido a Parrot, sin lo de HTB y con lo que pide el uso diario**.

---

## 1. Qué hay en este repositorio

```
personalizacion-con-QML/
├── README.md                 ← esta guía
├── docs/                     ← detalle técnico por tema (léelo según la fase)
│   ├── arquitectura.md       shell QML: estructura, servicios, IPC, convenciones
│   ├── componentes.md        cada pieza: qué hace, teclas, archivos
│   ├── themegen.md           paleta desde el fondo (OKLCH) y temas de apps
│   ├── arranque-y-login.md   Plymouth + SDDM (Parrot) y cómo hacerlo en Arch
│   ├── terminal-y-nvim.md    zsh, Starship, Fastfetch, kitty, Neovim tipo VSCode
│   ├── migracion-arch.md     cambios archivo por archivo para Arch (lo más importante)
│   ├── uso-diario.md         lo que hay que AÑADIR para el uso diario (bandeja, pomodoro...)
│   └── lecciones.md          trampas que ya costaron tiempo: no las repitas
├── parrot/                   ← INSTANTÁNEA EXACTA del sistema Parrot (referencia, funciona tal cual allí)
│   ├── home/                 rutas relativas a ~ (.config/quickshell, .config/hypr, .local/bin, ...)
│   └── system/               archivos fuera de ~ (sddm.conf.d, hook de apt, extractos de grub)
└── vault/                    ← copia de la bóveda de Obsidian: historia completa, decisión por decisión
```

**`parrot/` es una referencia, no algo para copiar a ciegas.** Funciona en Parrot; en Arch hay rutas, versiones y paquetes distintos (ver `docs/migracion-arch.md`). La **bóveda** (`vault/`) explica el *porqué* de cada cosa y los errores cometidos; ábrela cuando dudes de una decisión.

Excluido a propósito: los 64 fondos (49 MB; Arch tiene los suyos), y recursos generados (fuente copiada, fondo difuminado del login, máscara PNG del loro) que se regeneran con los scripts.

---

## 2. Cómo trabajar con este usuario (importante)

Estas reglas salen de dos días de trabajo con él. Respétalas:

1. **Español**, explicado **en simple**. No es experto en Linux; sí en pentesting. Evita jerga sin explicar.
2. **Quirúrgico**: copia de seguridad antes de cada cambio, un cambio a la vez, **verificar** antes de dar algo por bueno (capturas, logs, pruebas). Nunca digas "listo" sin haberlo comprobado; si algo no lo pudiste probar (p. ej. clics reales), **dilo**.
3. **Nunca escribas su contraseña.** Para `sudo`, ábrele una terminal flotante con el comando listo (`hyprctl dispatch exec "[float; size 860 460; center] kitty -o remember_window_size=no bash -c 'sudo ...; read x'"`) y espera a que termine. Él la escribe.
4. **Estética**: elegante, minimalista, sofisticada. **Sin emojis** en la interfaz, solo iconos Nerd Font. Paleta **siempre** desde el fondo.
5. **Documenta todo** en su bóveda de Obsidian (en Arch tiene Obsidian; crea una bóveda nueva o continúa esta copia). Él la usa para saber qué se hizo.
6. Antes de algo arriesgado (arranque, login, GRUB) **explica el riesgo y pide confirmación**. Ten siempre un plan para volver atrás.
7. Cuando cambies de fondo de pantalla, **todo** debe recolorearse (barra, terminal, apps, nvim, bordes...). Es la seña de identidad del proyecto.

---

## 3. Estado de partida en Arch (lo que encontré, solo lectura)

- **Hyprland 0.56.2**, `kitty`, `zsh` + oh-my-zsh, `starship`, `fastfetch`, `neovim 0.12.5`, `cava 1.0`, `yay`, `flatpak`, `steam`, `discord`.
- **Barra**: Waybar con 3 configs (`config-dp2`, `config-others`, `config`). Módulos: workspaces, ventana, reloj, **pomodoro**, **próximo evento (khal)**, **bandeja (tray)**, **actualizaciones (checkupdates + yay)**, audio + micro, cpu, memoria, red, **git**, **VPN**, **latencia**, mpris, energía.
- **Menús**: Rofi (lanzador, fondos, energía, chuleta de atajos) y un **menú estilo Omarchy** (`Super+Space`: instalar, actualizar, tema, fondo, portapapeles, notas rápidas, panel de control, atajos, apagar).
- **Colores**: matugen + wallust + pywal (`~/.cache/wal/colors.json`) aplicados por `apply-colors.sh`; **temas con nombre** en `~/.config/omarchy-theme/themes/` (`theme-set.sh`, selector en `Super+Ctrl+Shift+Space`). Fondos con **awww** (fork de swww).
- **Notificaciones**: dunst. **OSD**: `osd.sh` (swayosd si existe). **Portapapeles**: cliphist + rofi. **Bloqueo**: hyprlock + hypridle.
- **Atajos**: `Super+Q` terminal, `Super+C` cerrar, `Super+R` rofi, `Super+E` gestor de archivos (**nemo**), `Super+W` fondos, `Super+H` chuleta, `Super+S` scratchpad, `Super+Space` menú, `Super+M` salir. **Distintos de Parrot** (ver §6).
- **Login**: `display-manager.service -> lightdm`. **Arranque**: GRUB con tema `Elegant-mojave-window-left-dark`, `GRUB_TIMEOUT=300`, menú visible. `mkinitcpio` sin `plymouth`.
- Cursor `Ghostline-Dark`. `QT_QPA_PLATFORMTHEME=qt5ct`. Gaming: `setup-gaming-daily.sh` (gamemode, mangohud, gamescope, lutris, wine, protonup-qt, ufw...).
- Hay un repo antiguo de estos dotfiles (`github.com/N1C0L4S-OPS/dotfile-arch-linux`), **más viejo que el sistema real**: fíate del sistema, no del repo.

Verifica todo esto tú mismo antes de empezar: pueden haber cambiado cosas.

---

## 4. Principios de la shell (no los rompas)

- **Una sola shell QML** sustituye a waybar, rofi, dunst/swaync, hyprpaper/awww, swayosd y hyprlock. Todo comparte `config/Theme.qml` (paleta, tipografía Inter + JetBrainsMono Nerd Font Propo, radios, curva `[0.05, 0.7, 0.1, 1]`, duraciones 160/320/600 ms).
- **Paleta**: `~/.local/bin/themegen` analiza el fondo (k-means en OKLab) y escribe `~/.cache/hyprshell/colors.json` + colores de Hyprland, kitty, apps GTK/Qt; nvim lo lee en vivo. **Fidelidad**: usa los colores reales del fondo, no se inventa tonos. Ver `docs/themegen.md`.
- **Un panel a la vez** (`services/Ui.qml`). Paneles con entrada animada, blur del compositor (`layerrule`), Esc / clic fuera cierra.
- **IPC** para todo (`qs ipc call ...`): útil para atajos y para que TÚ pruebes sin teclado ni ratón.
- **Sin rebotes**: animaciones de Hyprland con las mismas curvas que la shell.
- **Seguridad por defecto**: el historial del portapapeles vive en RAM; el bloqueo usa `WlSessionLock` con respaldo de hyprlock y `allow_session_lock_restore`.

---

## 5. Plan de migración por fases

Cada fase termina con **una comprobación** y una nota en la bóveda. No pases a la siguiente sin verificar. Detalle archivo por archivo en **`docs/migracion-arch.md`**.

| Fase | Qué | Riesgo | Comprobación |
|---|---|---|---|
| **0. Preparación** | Copia de `~/.config`, `~/.local/bin`, lista de paquetes (`pacman -Qqe`), snapshot si usa timeshift. **Cambiar LightDM → SDDM** (trampa nº 1). Instalar paquetes base (§7). Decidir atajos con el usuario. | Medio (login) | Inicia sesión 3 veces: teclado y ratón responden siempre. |
| **1. Base** | `themegen` (adaptado) + `quickshell` con `Theme`, `Background`, `Bar` **para 3 monitores**, workspaces (1-5 DP-2, 6-10 DP-1, 11-15 HDMI-A-1). Waybar sigue disponible como respaldo. | Bajo | Barras en los 3 monitores, fondo con fundido, `Super+W` recolorea todo. |
| **2. Paneles** | Lanzador, fondos, energía, notificaciones (sustituye dunst), OSD, desplegables, calendario, **bandeja del sistema** (nuevo, obligatorio). | Bajo | Discord/Steam aparecen en la bandeja; notificaciones y OSD funcionan. |
| **3. Bloqueo** | `modules/lock` + `hypridle.conf` (Parrot: 10 min bloquear, 20 min apagar monitores, sin suspender; **pregúntale**, en uso diario quizá quiera suspender). | Medio | Modo prueba (`qs ipc call lock preview`) antes del bloqueo real. |
| **4. Productividad** | Vista general (`Super+Tab`), portapapeles (`Super+V`: **conflicto** con "flotante" en Arch), centro de control, instalador de paquetes (**pacman / AUR / Flatpak**, con pestaña de actualizaciones). | Bajo | Probar cada panel por IPC y capturas. |
| **5. Uso diario** | Lo nuevo de `docs/uso-diario.md`: bandeja, pomodoro, próximo evento, actualizaciones, notas rápidas, temas con nombre, **modo juego**. | Bajo | Según cada función. |
| **6. Apps, cursor, animaciones** | `themegen-apps` adaptado (base GTK distinta: ver doc), qt6ct, iconos, Bibata, animaciones sin rebote. | Bajo | Abrir Nemo/Dolphin, una app GTK y una Qt. |
| **7. Terminal y Neovim** | zsh con prompt transitorio, Starship **sin módulos HTB**, Fastfetch con **logo de Arch**, Neovim **sin fijar versiones** (Arch tiene 0.12). | Bajo | 10 tipos de archivo abren con su LSP sin avisos. |
| **8. Arranque y login** | Plymouth (hook de mkinitcpio) + tema SDDM. **GRUB: no tocar sin permiso explícito** (es el de toda la máquina). | **Alto** | Reinicio con el usuario delante; `linux-lts` o initramfs fallback como respaldo. |
| **9. Retirada** | Cuando todo tenga paridad: quitar waybar/rofi/dunst/matugen/wallust/awww de los `exec-once` (no desinstalar sin preguntar). | Bajo | Una sesión completa sin ellos. |

---

## 6. Lo que se quita, se cambia y se añade

### Se quita (era para HTB)
Barra: `Prompt.qml` (prompt `user@host:~`), `HtbTarget.qml`, `Htb.qml`, `ListenersButton.qml`, `RevShellButton.qml`, `AnonButton.qml`. Desplegables: `RevShellPop.qml`, `ListenersPop.qml`, y en `NetPop.qml` la IP de VPN de HTB. Servicios: `Target.qml`, `Listeners.qml`, `Anon.qml`, `SysInfo.vpnIp` (o dejarla genérica para una VPN normal). Centro de control: casillas **AnonSurf** y **VPN HTB**. Terminal: `htb_helpers.sh` (settarget, mktarget, extractports...), módulos `env_var.TARGET_*` de Starship, bloque "HTB" de Fastfetch (vpn/target). Hyprland: regla de ventana `htb-target`. Rutas `/etc/...` de apt/Parrot. Lista exacta en `docs/migracion-arch.md`.

### Se cambia
- **Atajos**: decídelo **con el usuario** antes de empezar. Arch usa `Super+Q` terminal / `Super+C` cerrar / `Super+Space` menú / `Super+V` flotante; Parrot usa `Super+Enter` terminal / `Super+Q` cerrar / `Super+C` centro de control / `Super+V` portapapeles. Propuesta: mantener los de Arch (su memoria muscular de uso diario), poner el centro de control en `Super+Space` (sustituye al menú Omarchy, que hace lo mismo) y el portapapeles en `Super+Shift+V` o donde él diga.
- **Paquetes**: `apt` → `pacman` + `yay` (AUR) en el instalador y en `themegen-apps` (rutas de temas e iconos).
- **3 monitores** en `Bar.qml`, `Overview.qml`, `Theme.primaryMonitor`.
- **Logos**: loro de Parrot → logo de Arch (glifo Nerd Font `linux-archlinux` U+F303 y `/usr/share/pixmaps/archlinux-logo.svg`).

### Se añade (uso diario)
Bandeja del sistema, pomodoro, próximo evento, indicador y pestaña de actualizaciones, notas rápidas, temas con nombre (los `omarchy-theme` existentes) además de la paleta desde el fondo, modo juego (sin blur ni animaciones con un juego en pantalla completa; gamemode), quizá brillo de monitores por DDC. Especificación en `docs/uso-diario.md`.

---

## 7. Paquetes en Arch (comprobado en la base de datos de pacman del Arch el 3 oct; todo en `extra` salvo lo marcado AUR)

- Shell: **`quickshell` 0.3.1 está en `extra`** (repos oficiales; Parrot usaba 0.3.0). `hyprpolkitagent` (no está instalado en Arch).
- Paleta: `python-numpy`, `python-pillow` (ya están), `imagemagick` (máscara del logo).
- Login/arranque: `sddm` (ya), `plymouth`.
- Utilidades: `wl-clipboard`, `grim`, `slurp`, `cava` (ya), `hyprsunset`, `wf-recorder`, `hyprpicker`, `power-profiles-daemon`, `pamixer`, `hypridle` (ya), `hyprlock` (respaldo), `hyprpolkitagent`.
- Apariencia: `ttf-jetbrains-mono-nerd`, `inter-font`, `bibata-cursor-theme-bin` (**AUR**), `qt6ct` (ya), `kvantum` (ya), `adw-gtk-theme` (base GTK para recolorear, ver `docs/themegen.md`), `papirus-icon-theme`.
- Uso diario: `khal` (calendario), `gamemode` (ya), `ddcutil` (brillo por DDC), `swayosd` (no hace falta: la shell tiene su OSD).
- Terminal/editor: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf`, `eza`, `bat`, `ripgrep`, `fd`, `npm`.

---

## 8. Trampas conocidas (resumen; detalle en `docs/lecciones.md`)

1. **LightDM + Hyprland = teclado y ratón muertos a ratos** (carrera de LightDM/Xorg con Hyprland por la terminal virtual). En Parrot se arregló **cambiando a SDDM**. El Arch usa LightDM: arréglalo en la fase 0.
2. **`pkill -f` / `pgrep -f` se encuentran a sí mismos** si el patrón aparece en el propio comando. Usa `pgrep -x` y compara la línea de comandos.
3. **Quickshell cachea el QML cargado por `Loader`**: tras editar un desplegable, reinicia `qs` (`pkill -x qs; hyprctl dispatch exec qs`).
4. **Qt simula "el ratón se movió" cuando el contenido se desplaza bajo un cursor quieto** → las listas saltaban. Solución en lanzador/paquetes/portapapeles: solo contar movimiento si cambia la posición en pantalla (`mapToItem(null, ...)`) y desplazamiento anticipado solo con teclado.
5. **Capturas y paneles**: los paneles abren en el **monitor con el foco**; mira dónde está la capa (`hyprctl layers -j`) antes de recortar una captura.
6. **Las ventanas de tamaño fijo no pueden ir en mosaico** en Hyprland (ni con `togglefloating`); prueba el mosaico con ventanas redimensionables.
7. **Glifos Nerd Font del rango U+E000–F8FF se pueden perder en heredocs**: escríbelos por código (`""` en Python) y verifica bytes con `od`.
8. **Las actualizaciones reponen el tema de Plymouth de la distro**: en Parrot se protegió con un hook de apt; en Arch usa un hook de **pacman** (`/etc/pacman.d/hooks/`).
9. **`kitty remember_window_size`** pisa las reglas de tamaño de Hyprland: usa `-o remember_window_size=no` en ventanas flotantes propias.
10. **`ssh -T git@github.com` termina con código 1** aunque funcione. Y `SSH_AUTH_SOCK` solo aplica a terminales abiertas después de configurarlo.

---

## 9. Lista de comprobación final (paridad con Parrot, sin HTB)

- [ ] Login SDDM propio (usuario escrito a mano, contraseña con barras), sin fallos de entrada.
- [ ] Carga Plymouth con el logo de Arch, transición sin cortes.
- [ ] Barras en 3 monitores, **limpias**: en Parrot el usuario las sintió demasiado cargadas (ver `docs/uso-diario.md`).
- [ ] `Super+W` recolorea: barra, bordes, kitty, nvim, GTK, Qt, iconos (y el login con su script).
- [ ] Lanzador, fondos, energía, notificaciones, OSD, calendario, bandeja.
- [ ] Bloqueo con barras, hypridle con los tiempos que elija.
- [ ] Vista general, portapapeles (RAM), centro de control, instalador (pacman/AUR/Flatpak + actualizaciones).
- [ ] Terminal (zsh transitorio, Starship, Fastfetch Arch), Neovim tipo VSCode con LSP.
- [ ] Cursor Bibata, animaciones sin rebote, apps con la paleta (navegadores excluidos).
- [ ] Funciones de uso diario acordadas.
- [ ] Todo documentado en la bóveda.

---

## Para el usuario

Este repositorio guarda **todo** lo que hicimos en Parrot:
- la configuración exacta, en `parrot/`;
- tu bóveda de Obsidian, en `vault/`;
- una guía para que otro Claude lo lleve a tu Arch, adaptado a uso diario y sin lo de HTB.

Para empezar en Arch:
1. Clona el repositorio.
2. Abre Claude Code en esa carpeta.
3. Dile: *"Lee el README y empecemos por la fase 0"*.

Él te pedirá decidir los atajos de teclado antes de empezar.
