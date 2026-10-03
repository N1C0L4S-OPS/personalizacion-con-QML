# GitHub por SSH

Configurado el 3 oct. Cuenta: **N1C0L4S-OPS**.

## Llave
- `~/.ssh/id_ed25519` (privada, 600) / `.pub` - ED25519, comentario `sethdeymos@parrot`, **con frase de contrasena**.
- Huella: `SHA256:sh4TbQHB7OnhB9QELwP4H253QYgwsG+l4EscoheBq0k`.
- Registrada en GitHub (Settings -> SSH and GPG keys). Verificado: `ssh -T git@github.com` -> "Hi N1C0L4S-OPS!".

## Agente (la frase se pide una vez por sesion)
- `systemctl --user enable --now ssh-agent.socket` -> socket `/run/user/1000/openssh_agent`.
- `SSH_AUTH_SOCK` en hyprland.conf (`env`) y en `~/.zshrc`.
- `~/.ssh/config`: `Host github.com` con `IdentityFile ~/.ssh/id_ed25519`, `IdentitiesOnly yes`, `AddKeysToAgent yes`.

## Uso
- Clonar: `git clone git@github.com:N1C0L4S-OPS/personalizacion-con-QML.git`
- Repos clonados por HTTPS: `git remote set-url origin git@github.com:USUARIO/REPO.git`
- `ssh -T` siempre termina con codigo 1 (GitHub no da shell): es normal.

## Pendiente
Identidad de git (`user.name` / `user.email`) para los commits.

Relacionado: [[Pendiente - hoja de ruta]].
