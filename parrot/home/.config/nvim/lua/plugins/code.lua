-- Inteligencia de codigo (LSP), autocompletado, formateo, git, terminal y ejecutar
-- Versiones fijadas a las compatibles con nvim 0.10.
local servers = { "pyright", "bashls", "lua_ls", "ts_ls", "html", "cssls", "jsonls", "clangd", "marksman", "yamlls" }
-- Los que se instalan con npm solo se piden si npm existe (si no, mason los reintenta en cada inicio)
local npm_based = { pyright = true, bashls = true, ts_ls = true, html = true, cssls = true, jsonls = true, yamlls = true }
local function installable()
  local has_npm = vim.fn.executable("npm") == 1
  return vim.tbl_filter(function(s) return has_npm or not npm_based[s] end, servers)
end

return {
  { "williamboman/mason.nvim", version = "^1", cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog" }, build = ":MasonUpdate",
    opts = { ui = { border = "rounded", icons = { package_installed = "", package_pending = "", package_uninstalled = "" } } } },
  { "williamboman/mason-lspconfig.nvim", version = "^1" },
  { "neovim/nvim-lspconfig", version = "^1", event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp", "SmiteshP/nvim-navic" },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({ ensure_installed = installable(), automatic_installation = false })
      local caps = require("cmp_nvim_lsp").default_capabilities()
      local lsp = require("lspconfig")
      local settings = {
        lua_ls = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false }, telemetry = { enable = false } } },
      }
      -- Solo se configuran los servidores realmente instalados (evita avisos de "no encontrado")
      require("mason-lspconfig").setup_handlers({
        function(s) lsp[s].setup({ capabilities = caps, settings = settings[s] }) end,
      })
      vim.diagnostic.config({
        virtual_text = { prefix = "●", spacing = 2 },
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        signs = { text = { [vim.diagnostic.severity.ERROR] = "", [vim.diagnostic.severity.WARN] = "", [vim.diagnostic.severity.INFO] = "", [vim.diagnostic.severity.HINT] = "󰌵" } },
      })
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local m = function(l, r, d) vim.keymap.set("n", l, r, { buffer = ev.buf, desc = d }) end
          m("gd", vim.lsp.buf.definition, "Ir a la definicion")
          m("gr", "<cmd>Telescope lsp_references<cr>", "Referencias")
          m("K", vim.lsp.buf.hover, "Documentacion")
          m("<leader>ca", vim.lsp.buf.code_action, "Acciones rapidas")
          m("<leader>cr", vim.lsp.buf.rename, "Renombrar")
        end,
      })
    end },

  -- Autocompletado tipo VSCode: aparece solo, Tab/Enter acepta, documentacion al lado
  { "hrsh7th/nvim-cmp", event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline",
                     { "L3MON4D3/LuaSnip", version = "v2.*" }, "saadparwaiz1/cmp_luasnip", "rafamadriz/friendly-snippets", "onsails/lspkind.nvim" },
    config = function()
      local cmp, luasnip = require("cmp"), require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()   -- snippets de VSCode
      cmp.setup({
        snippet = { expand = function(a) luasnip.lsp_expand(a.body) end },
        window = { completion = cmp.config.window.bordered({ winhighlight = "Normal:Pmenu,CursorLine:PmenuSel,FloatBorder:FloatBorder" }),
                   documentation = cmp.config.window.bordered() },
        experimental = { ghost_text = true },
        formatting = { format = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 40, ellipsis_char = "…" }) },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fb)
            if cmp.visible() then cmp.confirm({ select = true })
            elseif luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump()
            else fb() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fb)
            if luasnip.locally_jumpable(-1) then luasnip.jump(-1) else fb() end
          end, { "i", "s" }),
          ["<Down>"] = cmp.mapping.select_next_item(), ["<Up>"] = cmp.mapping.select_prev_item(),
          ["<Esc>"] = cmp.mapping(function(fb) if cmp.visible() then cmp.abort() end fb() end),
        }),
        sources = cmp.config.sources({ { name = "nvim_lsp" }, { name = "luasnip" }, { name = "path" } }, { { name = "buffer" } }),
      })
      cmp.setup.cmdline(":", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "path" }, { name = "cmdline" } } })
      cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
    end },

  -- Formateo (Shift+Alt+F); si no hay formateador, usa el del LSP
  { "stevearc/conform.nvim", version = "^7", cmd = "ConformInfo", lazy = true,
    opts = { formatters_by_ft = { lua = { "stylua" }, python = { "ruff_format", "black", stop_after_first = true },
                                  sh = { "shfmt" }, javascript = { "prettier" }, typescript = { "prettier" }, json = { "prettier" },
                                  html = { "prettier" }, css = { "prettier" }, yaml = { "prettier" }, markdown = { "prettier" } } } },

  -- Panel de problemas (como el de VSCode)
  { "folke/trouble.nvim", cmd = "Trouble", opts = {},
    keys = { { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Problemas (todo)" },
             { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Problemas (archivo)" },
             { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs" } } },

  -- Git en el margen + acciones
  { "lewis6991/gitsigns.nvim", version = "*", event = "BufReadPre",   -- version publicada (la de desarrollo exige nvim 0.11)
    opts = { signs = { add = { text = "▎" }, change = { text = "▎" }, delete = { text = "▁" }, topdelete = { text = "▔" }, changedelete = { text = "▎" } },
             current_line_blame_opts = { delay = 400 },
             on_attach = function(b)
               local gs = require("gitsigns")
               local m = function(l, r, d) vim.keymap.set("n", l, r, { buffer = b, desc = d }) end
               m("<leader>gb", gs.toggle_current_line_blame, "Autor de la linea (blame)")
               m("<leader>gp", gs.preview_hunk, "Ver cambio")
               m("<leader>gr", gs.reset_hunk, "Deshacer cambio")
               m("]h", gs.next_hunk, "Siguiente cambio"); m("[h", gs.prev_hunk, "Cambio anterior")
             end } },

  -- Terminal integrada: Ctrl+` (o Ctrl+T) abajo, como VSCode
  { "akinsho/toggleterm.nvim", version = "*",
    keys = { { "<C-`>", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal", mode = { "n", "i", "t" } },
             { "<C-t>", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal", mode = { "n", "i", "t" } },
             { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal flotante" },
             { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=70<cr>", desc = "Terminal vertical" } },
    opts = { size = 14, shade_terminals = false, float_opts = { border = "rounded" } } },

  -- Ejecutar el archivo actual (F5)
  { "CRAG666/code_runner.nvim", cmd = { "RunCode", "RunFile" },
    keys = { { "<F5>", "<cmd>w<cr><cmd>RunFile term<cr>", desc = "Ejecutar archivo" } },
    opts = { filetype = { python = "python3 -u", sh = "bash", bash = "bash", javascript = "node", lua = "lua",
                          c = { "cd $dir &&", "gcc $fileName -o /tmp/$fileNameWithoutExt &&", "/tmp/$fileNameWithoutExt" },
                          cpp = { "cd $dir &&", "g++ $fileName -o /tmp/$fileNameWithoutExt &&", "/tmp/$fileNameWithoutExt" },
                          go = "go run", rust = { "cd $dir &&", "rustc $fileName -o /tmp/$fileNameWithoutExt &&", "/tmp/$fileNameWithoutExt" },
                          php = "php" } } },

}
