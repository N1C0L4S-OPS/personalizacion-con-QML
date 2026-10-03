local au = vim.api.nvim_create_autocmd

-- Resalta brevemente lo copiado
au("TextYankPost", { callback = function() vim.highlight.on_yank({ timeout = 180 }) end })

-- Vuelve a la ultima posicion del cursor al abrir un archivo
au("BufReadPost", {
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Ventanas auxiliares se cierran con q
au("FileType", {
  pattern = { "help", "qf", "man", "lspinfo", "checkhealth", "notify", "spectre_panel", "startuptime" },
  callback = function(ev) vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true }) end,
})

-- Recarga el archivo si cambio fuera de nvim
au({ "FocusGained", "BufEnter" }, { command = "checktime" })

-- Markdown y texto: ajuste de linea
au("FileType", { pattern = { "markdown", "text", "gitcommit" }, callback = function() vim.opt_local.wrap = true; vim.opt_local.linebreak = true end })
