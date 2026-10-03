-- Tema a partir de la paleta del fondo (themegen -> ~/.cache/hyprshell/colors.json).
-- Se recarga solo cuando cambias de fondo (Super+W), aunque nvim este abierto.
local M = {}
local path = vim.fn.expand("~/.cache/hyprshell/colors.json")

local function read()
  local f = io.open(path, "r")
  if not f then return nil end
  local ok, data = pcall(vim.json.decode, f:read("*a"))
  f:close()
  return ok and data or nil
end

function M.apply()
  local p = read()
  if not p then return end
  local ok, base16 = pcall(require, "mini.base16")
  if not ok then return end
  base16.setup({
    palette = {
      base00 = p.bg, base01 = p.surface, base02 = p.surface2, base03 = p.fgDim,
      base04 = p.fgMuted, base05 = p.fg, base06 = p.fg, base07 = p.fg,
      base08 = p.red, base09 = p.yellow, base0A = p.yellow, base0B = p.green,
      base0C = p.cyan, base0D = p.accent, base0E = p.magenta, base0F = p.accent2,
    },
    use_cterm = false,
  })
  vim.g.colors_name = "hyprshell"
  local hl = function(n, v) vim.api.nvim_set_hl(0, n, v) end
  -- Fondo transparente: se ve la transparencia de kitty
  for _, g in ipairs({ "Normal", "NormalNC", "SignColumn", "LineNr", "FoldColumn", "EndOfBuffer", "CursorLineNr", "CursorLineSign" }) do
    local cur = vim.api.nvim_get_hl(0, { name = g })
    cur.bg = nil
    hl(g, cur)
  end
  hl("CursorLine", { bg = p.surface })
  hl("CursorLineNr", { fg = p.accent, bold = true })
  hl("LineNr", { fg = p.fgDim })
  hl("NormalFloat", { bg = p.surface })
  hl("FloatBorder", { fg = p.overlay, bg = p.surface })
  hl("FloatTitle", { fg = p.accent, bg = p.surface, bold = true })
  hl("Pmenu", { bg = p.surface, fg = p.fgMuted })
  hl("PmenuSel", { bg = p.surface2, fg = p.fg, bold = true })
  hl("Visual", { bg = p.surface2 })
  hl("WinSeparator", { fg = p.surface2 })
  hl("StatusLine", { bg = "NONE" })
  hl("Comment", { fg = p.fgDim, italic = true })
  hl("Search", { bg = p.accentDim, fg = p.bg })
  hl("IncSearch", { bg = p.accent, fg = p.bg })
  hl("MatchParen", { fg = p.accent, bold = true, underline = true })
  hl("DiagnosticUnderlineError", { undercurl = true, sp = p.red })
  hl("DiagnosticUnderlineWarn", { undercurl = true, sp = p.yellow })
  hl("IblIndent", { fg = p.surface2 })
  hl("IblScope", { fg = p.overlay })
  vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "hyprshell" })
end

function M.palette() return read() end

function M.setup()
  M.apply()
  -- Vigila el archivo de colores: al cambiar el fondo, se recolorea en vivo
  local w = vim.uv.new_fs_event()
  local function watch()
    w:start(path, {}, vim.schedule_wrap(function()
      w:stop()
      vim.defer_fn(function() M.apply(); watch() end, 150)
    end))
  end
  if w then watch() end
end

return M
