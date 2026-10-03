-- Edicion y busqueda
return {
  -- Buscador universal: Ctrl+P archivos, F1 comandos, Ctrl+F en el archivo, Ctrl+Shift+F en todo el proyecto
  { "nvim-telescope/telescope.nvim", branch = "0.1.x", cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
    keys = {
      { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Abrir archivo", mode = { "n", "i" } },
      { "<F1>", "<cmd>Telescope commands<cr>", desc = "Paleta de comandos", mode = { "n", "i" } },
      { "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buscar en el archivo" },
      { "<C-S-f>", "<cmd>Telescope live_grep<cr>", desc = "Buscar en el proyecto", mode = { "n", "i" } },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Archivos" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Texto en el proyecto" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Palabra bajo el cursor" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recientes" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Pestanas abiertas" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Simbolos (Ctrl+Shift+O)" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Atajos" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Ayuda" },
    },
    config = function()
      local t = require("telescope")
      t.setup({
        defaults = {
          prompt_prefix = "    ", selection_caret = "▌ ", entry_prefix = "  ",
          layout_strategy = "horizontal", sorting_strategy = "ascending",
          layout_config = { prompt_position = "top", width = 0.86, height = 0.8, preview_width = 0.55 },
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          file_ignore_patterns = { "%.git/", "node_modules/", "__pycache__/" },
          mappings = { i = { ["<esc>"] = require("telescope.actions").close, ["<C-j>"] = "move_selection_next", ["<C-k>"] = "move_selection_previous" } },
        },
        pickers = {
          find_files = { hidden = true, find_command = vim.fn.executable("fdfind") == 1 and { "fdfind", "--type", "f", "--hidden", "--exclude", ".git" } or nil },
          commands = { theme = "dropdown", previewer = false },
          current_buffer_fuzzy_find = { theme = "dropdown", previewer = false },
        },
      })
      pcall(t.load_extension, "fzf")
    end },

  -- Resaltado de sintaxis preciso
  { "nvim-treesitter/nvim-treesitter", branch = "master", build = ":TSUpdate", event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "bash", "c", "cpp", "python", "lua", "javascript", "typescript", "tsx", "html", "css", "json", "yaml", "toml",
                             "markdown", "markdown_inline", "go", "rust", "php", "sql", "dockerfile", "regex", "vim", "vimdoc", "query", "diff", "gitcommit", "xml", "ini" },
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = { enable = true, keymaps = { init_selection = "<C-space>", node_incremental = "<C-space>", node_decremental = "<bs>" } },
      })
    end },
  { "windwp/nvim-ts-autotag", event = "InsertEnter", opts = {} },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = { check_ts = true } },

  -- Multicursor: Ctrl+D selecciona la siguiente coincidencia (como VSCode)
  { "mg979/vim-visual-multi", branch = "master", event = "BufReadPost",
    init = function()
      vim.g.VM_maps = { ["Find Under"] = "<C-d>", ["Find Subword Under"] = "<C-d>", ["Add Cursor Down"] = "<C-A-Down>", ["Add Cursor Up"] = "<C-A-Up>" }
      vim.g.VM_theme = "codedark"
    end },

  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },
  { "folke/flash.nvim", event = "VeryLazy", opts = { modes = { search = { enabled = false } } },
    keys = { { "s", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Saltar (flash)" } } },

  -- Buscar y reemplazar en todo el proyecto (Ctrl+H)
  { "nvim-pack/nvim-spectre", cmd = "Spectre", dependencies = "nvim-lua/plenary.nvim",
    keys = { { "<C-h>", function() require("spectre").toggle() end, desc = "Reemplazar en el proyecto" },
             { "<leader>sr", function() require("spectre").toggle() end, desc = "Reemplazar en el proyecto" } },
    opts = { open_cmd = "noswapfile vnew" } },

  -- Sesiones: reabrir lo que tenias abierto (como VSCode)
  { "folke/persistence.nvim", event = "BufReadPre", opts = {},
    keys = { { "<leader>ss", function() require("persistence").load() end, desc = "Restaurar sesion" },
             { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Ultima sesion" } } },

  { "mbbill/undotree", cmd = "UndotreeToggle", keys = { { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Historial de cambios" } } },
}
