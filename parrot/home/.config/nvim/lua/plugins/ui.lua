-- Interfaz: explorador, pestanas, barra de estado, bienvenida, paleta de comandos...
local pal = function() return require("config.theme").palette() or {} end

return {
  { "echasnovski/mini.nvim", version = false, lazy = false, priority = 1000,
    config = function()
      require("mini.bufremove").setup()
    end },
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Explorador lateral (Ctrl+B), como el de VSCode
  { "nvim-neo-tree/neo-tree.nvim", branch = "v3.x", cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<C-b>", "<cmd>Neotree toggle reveal<cr>", desc = "Explorador de archivos", mode = { "n", "i" } },
      { "<leader>e", "<cmd>Neotree focus reveal<cr>", desc = "Ir al explorador" },
      { "<leader>ge", "<cmd>Neotree float git_status<cr>", desc = "Cambios de git" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      default_component_configs = {
        indent = { with_expanders = true },
      },
      window = { width = 32, mappings = { ["<space>"] = "none", ["l"] = "open", ["h"] = "close_node" } },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false, hide_by_name = { ".git" } },
      },
    } },

  -- Pestanas arriba
  { "akinsho/bufferline.nvim", version = "*", event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        close_command = function(n) require("mini.bufremove").delete(n, false) end,
        right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        separator_style = "thin",
        indicator = { style = "underline" },
        show_buffer_close_icons = true,
        hover = { enabled = true, delay = 120, reveal = { "close" } },
        offsets = { { filetype = "neo-tree", text = "EXPLORADOR", highlight = "Directory", text_align = "left" } },
      },
    } },

  -- Barra de estado + migas de pan (ruta del simbolo actual) arriba de cada ventana
  { "SmiteshP/nvim-navic", lazy = true, opts = { lsp = { auto_attach = true }, highlight = true, separator = "  ", depth_limit = 5 } },
  { "nvim-lualine/lualine.nvim", event = "VeryLazy",
    config = function()
      local function setup()
        local p = pal()
        local function mode(c) return { a = { fg = p.bg, bg = c, gui = "bold" }, b = { fg = p.fg, bg = p.surface2 }, c = { fg = p.fgMuted, bg = "NONE" } } end
        local theme = {
          normal = mode(p.accent), insert = mode(p.green), visual = mode(p.magenta),
          replace = mode(p.red), command = mode(p.yellow), select = mode(p.accent2),
          inactive = { a = { fg = p.fgDim, bg = "NONE" }, b = { fg = p.fgDim, bg = "NONE" }, c = { fg = p.fgDim, bg = "NONE" } },
        }
        require("lualine").setup({
          options = { theme = theme, globalstatus = true, component_separators = "", section_separators = { left = "", right = "" },
                      disabled_filetypes = { winbar = { "neo-tree", "toggleterm", "alpha", "trouble", "spectre_panel" } } },
          sections = {
            lualine_a = { { "mode", fmt = function(s) return ({ NORMAL = "NORMAL", INSERT = "INSERTAR", VISUAL = "VISUAL", ["V-LINE"] = "V-LINEA", ["V-BLOCK"] = "V-BLOQUE", SELECT = "SELECCION", REPLACE = "REEMPLAZAR", COMMAND = "COMANDO", TERMINAL = "TERMINAL" })[s] or s end } },
            lualine_b = { { "branch", icon = "󰘬" }, "diff" },
            lualine_c = { { "filename", path = 1, symbols = { modified = " ●", readonly = " 󰌾" } } },
            lualine_x = { "diagnostics", { "filetype", icon_only = false } },
            lualine_y = { { "encoding", fmt = string.upper }, "fileformat" },
            lualine_z = { { "location", fmt = function(s) return "Ln " .. s:gsub(":", ", Col ") end } },
          },
          winbar = { lualine_c = { { "navic", color_correction = "dynamic" } } },
          inactive_winbar = { lualine_c = {} },
        })
      end
      setup()
      vim.api.nvim_create_autocmd("ColorScheme", { pattern = "hyprshell", callback = setup })
    end },

  -- Pantalla de bienvenida
  { "goolord/alpha-nvim", event = "VimEnter",
    config = function()
      local d = require("alpha.themes.dashboard")
      d.section.header.val = {
        "",
        "┏┓╻┏━╸┏━┓╻ ╻╻┏┳┓",
        "┃┗┫┣╸ ┃ ┃┃┏┛┃┃┃┃",
        "╹ ╹┗━╸┗━┛┗┛ ╹╹ ╹",
        "",
        "  parrot · hyprland",
        "",
      }
      d.section.buttons.val = {
        d.button("n", "  Nuevo archivo", "<cmd>enew<cr>"),
        d.button("p", "  Buscar archivo            Ctrl+P", "<cmd>Telescope find_files<cr>"),
        d.button("r", "  Recientes", "<cmd>Telescope oldfiles<cr>"),
        d.button("f", "  Buscar texto", "<cmd>Telescope live_grep<cr>"),
        d.button("s", "  Restaurar sesion", function() require("persistence").load() end),
        d.button("o", "  Notas (boveda)", "<cmd>cd ~/Documents/Parrot-Hyprland-Vault | Neotree reveal<cr>"),
        d.button("c", "  Configuracion", "<cmd>cd ~/.config/nvim | Telescope find_files<cr>"),
        d.button("l", "󰒲  Plugins", "<cmd>Lazy<cr>"),
        d.button("q", "  Salir", "<cmd>qa<cr>"),
      }
      for _, b in ipairs(d.section.buttons.val) do b.opts.hl = "Normal"; b.opts.hl_shortcut = "Function" end
      d.section.header.opts.hl = "Function"
      d.section.footer.val = "Espacio: menu de atajos  ·  F1: paleta de comandos"
      d.section.footer.opts.hl = "Comment"
      require("alpha").setup(d.opts)
    end },

  -- Ayuda de atajos al pulsar Espacio
  { "folke/which-key.nvim", event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>f", group = "Buscar" }, { "<leader>g", group = "Git" }, { "<leader>c", group = "Codigo" },
        { "<leader>x", group = "Problemas" }, { "<leader>t", group = "Terminal" }, { "<leader>s", group = "Sesion / reemplazar" },
        { "<leader>u", group = "Opciones" },
      },
    } },

  -- Linea de comandos centrada, tipo paleta de VSCode; avisos elegantes
  { "folke/noice.nvim", event = "VeryLazy", dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = { view = "cmdline_popup", format = { cmdline = { icon = "❯" }, search_down = { icon = " ⌄" }, search_up = { icon = " ⌃" } } },
      lsp = { override = { ["vim.lsp.util.convert_input_to_markdown_lines"] = true, ["vim.lsp.util.stylize_markdown"] = true, ["cmp.entry.get_documentation"] = true } },
      presets = { command_palette = true, long_message_to_split = true, lsp_doc_border = true },
      routes = { { filter = { event = "msg_show", kind = "", find = "escrito" }, opts = { skip = true } } },
    } },
  { "stevearc/dressing.nvim", event = "VeryLazy", opts = {} },

  -- Guias de sangria, colores en el codigo, TODOs
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", event = "BufReadPost",
    opts = { indent = { char = "│", highlight = "IblIndent" }, scope = { highlight = "IblScope", show_start = false, show_end = false } } },
  { "catgoose/nvim-colorizer.lua", event = "BufReadPost", opts = { user_default_options = { names = false, css = true } } },
  { "folke/todo-comments.nvim", event = "BufReadPost", dependencies = "nvim-lua/plenary.nvim", opts = {} },
}
