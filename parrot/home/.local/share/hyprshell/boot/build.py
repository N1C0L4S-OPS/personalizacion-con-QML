#!/usr/bin/env python3
"""Genera los recursos de arranque e inicio de sesion con la paleta y el fondo actuales.
   - sddm/hyprshell/      fondo difuminado, theme.conf con colores, fuente de iconos
   - plymouth/hyprshell/  loro, brillo, barras (imagenes del tema de Plymouth)
   - grub/background.png  fondo de la pantalla de carga de GRUB (= primer fotograma de Plymouth)
Luego: install.sh (con sudo) copia todo al sistema."""
import json, shutil
from pathlib import Path
import numpy as np
from PIL import Image, ImageFilter, ImageDraw

HOME = Path.home()
BOOT = HOME / ".local/share/hyprshell/boot"
pal = json.loads((HOME / ".cache/hyprshell/colors.json").read_text())
mask_src = Image.open(HOME / ".local/share/hyprshell/parrot-wings-mask.png").split()[3]
W, H = 1920, 1080
LOGO_H = 150                     # alto del loro en pantalla (px)
LOGO_CY = H // 2 - 30            # centro vertical del loro

def rgb(h): return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))

def parrot(height, c1, c2, alpha=1.0):
    m = mask_src.crop(mask_src.getbbox())
    w = round(m.width * height / m.height)
    m = m.resize((w, height), Image.LANCZOS)
    yy, xx = np.mgrid[0:height, 0:w]
    t = ((xx / max(w - 1, 1)) * 0.35 + (yy / max(height - 1, 1)) * 0.65)[..., None]
    g = np.array(c1) * (1 - t) + np.array(c2) * t
    a = (np.asarray(m, dtype=np.float64) * alpha)[..., None]
    return Image.fromarray(np.concatenate([g, a], axis=2).astype(np.uint8), "RGBA")

acc, acc2, bg, red = rgb(pal["accent"]), rgb(pal["accent2"]), rgb(pal["bg"]), rgb(pal["red"])
logo = parrot(LOGO_H, acc, acc2)

# ---------------- Plymouth ----------------
P = BOOT / "plymouth/hyprshell"
logo.save(P / "parrot.png")
pad = 60
glow = Image.new("RGBA", (logo.width + pad * 2, logo.height + pad * 2), (0, 0, 0, 0))
glow.paste(parrot(LOGO_H, acc, acc, 0.85), (pad, pad))
glow = glow.filter(ImageFilter.GaussianBlur(26))
glow.save(P / "glow.png")
Image.new("RGBA", (8, 8), acc + (255,)).save(P / "fill.png")
Image.new("RGBA", (8, 8), rgb(pal["overlay"]) + (255,)).save(P / "track.png")
for name, col in (("bar", acc), ("bar-red", red)):
    b = Image.new("RGBA", (4, 28), (0, 0, 0, 0)); ImageDraw.Draw(b).rounded_rectangle([0, 0, 3, 27], 2, fill=col + (255,)); b.save(P / f"{name}.png")
(P / "colors").write_text(" ".join(f"{v / 255:.4f}" for v in bg) + "\n")

# ---------------- GRUB: igual al primer fotograma de Plymouth ----------------
gimg = Image.new("RGB", (W, H), bg)
gimg.paste(logo, (W // 2 - logo.width // 2, LOGO_CY - logo.height // 2), logo)
gimg.save(BOOT / "grub/background.png")

# ---------------- SDDM ----------------
S = BOOT / "sddm/hyprshell"
wall = Image.open(pal["wallpaper"]).convert("RGB")
wall = wall.resize((W, round(wall.height * W / wall.width)) if wall.width / wall.height < W / H else (round(wall.width * H / wall.height), H), Image.LANCZOS)
l, t = (wall.width - W) // 2, (wall.height - H) // 2
wall = wall.crop((l, t, l + W, t + H)).filter(ImageFilter.GaussianBlur(42))
wall = Image.blend(wall, Image.new("RGB", (W, H), bg), 0.42)
wall.save(S / "background.jpg", quality=92)
font = HOME / ".local/share/fonts/NerdFonts/JetBrainsMonoNerdFontPropo-Regular.ttf"
if font.is_file():
    shutil.copy(font, S / "icons.ttf")
(S / "theme.conf").write_text("[General]\nbackground=background.jpg\n" + "".join(
    f"{k}={pal[k]}\n" for k in ("bg", "surface", "surface2", "overlay", "fg", "fgMuted", "fgDim", "accent", "accent2", "red", "yellow")))
print("recursos generados en", BOOT)
