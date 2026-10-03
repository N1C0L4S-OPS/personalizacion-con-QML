# Arreglo - entrada muerta (LightDM a SDDM)

## Sintoma
Al entrar en Hyprland, a veces no respondian ni el raton ni el teclado. Un dia si, otro no.

## Causa real
Una **carrera entre LightDM y Hyprland**. La pantalla de login de LightDM (slick-greeter) usa Xorg y arrancaba Hyprland en la misma terminal virtual; durante un instante los dos peleaban por la pantalla y por los dispositivos de entrada. Segun quien ganara, Hyprland se quedaba sin raton ni teclado. Esto explica que fuera intermitente y que KDE no lo sufriera.

Los "arreglos" anteriores (cursor por software, quitar `es,us`, seatd, variables `WLR_*`) no atacaban la causa y no sirvieron. De hecho Hyprland 0.55 ni siquiera lee esas variables `WLR_*` (usa aquamarine, no wlroots).

## Solucion
Cambiar el gestor de inicio de **LightDM** a **SDDM** (ya estaba instalado), que arranca las sesiones Wayland en una terminal virtual propia y evita la carrera.

```bash
echo /usr/bin/sddm | sudo tee /etc/X11/default-display-manager
sudo systemctl enable --force sddm
```

Confirmado funcionando: raton y teclado responden en cada arranque.

## Extra
Se creo `~/.config/hypr/scripts/persist-log.sh`, que copia el log de Hyprland a `~/.cache/hypr-logs/` cada 2 s, para no perder el rastro si algo se congela y hay que apagar a la fuerza.

Relacionado: [[Copias de seguridad y rutas]].
