-- ============================================================================
--  Neovim con comodidad de VSCode (Parrot + Hyprland)
--  Colores: la paleta del fondo (~/.cache/hyprshell/colors.json), en vivo.
--  Atajos: ver lua/config/keymaps.lua  ·  Espacio = menu de atajos (which-key)
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")

-- lazy.nvim (gestor de plugins)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  install = { colorscheme = { "default" } },
  checker = { enabled = false },
  change_detection = { notify = false },
  ui = { border = "rounded", title = " plugins " },
  performance = { rtp = { disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin", "netrwPlugin" } } },
})

require("config.theme").setup()
require("config.keymaps")
require("config.autocmds")
