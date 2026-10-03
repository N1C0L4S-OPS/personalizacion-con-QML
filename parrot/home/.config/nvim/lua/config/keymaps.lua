-- Atajos tipo VSCode (ademas de todos los de Vim). <Espacio> abre el menu con el resto.
local map = function(mode, lhs, rhs, desc, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true, desc = desc }, opts or {}))
end

-- Archivo
map({ "n", "i", "v", "s" }, "<C-s>", "<cmd>write<cr><esc>", "Guardar")
map({ "n", "i", "v" }, "<C-q>", "<cmd>confirm qall<cr>", "Salir")

-- Deshacer / rehacer / seleccionar todo
map({ "n", "i" }, "<C-z>", "<cmd>undo<cr>", "Deshacer")
map({ "n", "i" }, "<C-y>", "<cmd>redo<cr>", "Rehacer")
map("n", "<C-a>", "ggVG", "Seleccionar todo")
map("i", "<C-a>", "<esc>ggVG", "Seleccionar todo")

-- Copiar / cortar / pegar (portapapeles del sistema)
map("v", "<C-c>", '"+y', "Copiar")
map("v", "<C-x>", '"+d', "Cortar")
map("s", "<C-c>", '<C-g>"+y', "Copiar")
map("s", "<C-x>", '<C-g>"+d', "Cortar")
map("n", "<C-v>", '"+p', "Pegar")
map("v", "<C-v>", '"_d"+P', "Pegar sobre la seleccion")
map("i", "<C-v>", "<C-r><C-o>+", "Pegar")
map("n", "<A-v>", "<C-v>", "Seleccion en bloque (la de Vim)")

-- Comentar (Ctrl+/ llega como Ctrl+_ en la terminal)
map("n", "<C-/>", "gcc", "Comentar linea", { remap = true })
map("n", "<C-_>", "gcc", "Comentar linea", { remap = true })
map("v", "<C-/>", "gc", "Comentar seleccion", { remap = true })
map("v", "<C-_>", "gc", "Comentar seleccion", { remap = true })
map("i", "<C-/>", "<esc>gcca", "Comentar linea", { remap = true })
map("i", "<C-_>", "<esc>gcca", "Comentar linea", { remap = true })

-- Borrar palabra con Ctrl+Retroceso / Ctrl+Supr
map("i", "<C-h>", "<C-w>", "Borrar palabra atras")
map("i", "<C-BS>", "<C-w>", "Borrar palabra atras")
map("i", "<C-Del>", "<C-o>dw", "Borrar palabra adelante")

-- Mover / duplicar lineas
map("n", "<A-Up>", "<cmd>m .-2<cr>==", "Subir linea")
map("n", "<A-Down>", "<cmd>m .+1<cr>==", "Bajar linea")
map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", "Subir linea")
map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", "Bajar linea")
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", "Subir seleccion")
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", "Bajar seleccion")
map("n", "<S-A-Down>", "<cmd>t.<cr>", "Duplicar linea abajo")
map("n", "<S-A-Up>", "<cmd>t-1<cr>", "Duplicar linea arriba")

-- Sangria con Tab en seleccion
map("v", "<Tab>", ">gv", "Sangrar")
map("v", "<S-Tab>", "<gv", "Quitar sangria")

-- Pestanas (buffers)
map("n", "<C-PageDown>", "<cmd>BufferLineCycleNext<cr>", "Pestana siguiente")
map("n", "<C-PageUp>", "<cmd>BufferLineCyclePrev<cr>", "Pestana anterior")
map("n", "<C-w>", function() require("mini.bufremove").delete(0, false) end, "Cerrar pestana")
for i = 1, 9 do
  map("n", "<A-" .. i .. ">", "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", "Ir a pestana " .. i)
end

-- Ventanas (divisiones): Alt + h/j/k/l
map("n", "<A-h>", "<C-w>h", "Ventana izquierda")
map("n", "<A-j>", "<C-w>j", "Ventana abajo")
map("n", "<A-k>", "<C-w>k", "Ventana arriba")
map("n", "<A-l>", "<C-w>l", "Ventana derecha")
map("n", "<C-\\>", "<cmd>vsplit<cr>", "Dividir a la derecha")

-- Buscar
map("n", "<Esc>", "<cmd>nohlsearch<cr>", "Quitar resaltado de busqueda")

-- Codigo (LSP): los de VSCode
map("n", "<F2>", vim.lsp.buf.rename, "Renombrar simbolo")
map("n", "<F12>", vim.lsp.buf.definition, "Ir a la definicion")
map("n", "<S-F12>", "<cmd>Telescope lsp_references<cr>", "Referencias")
map({ "n", "v" }, "<C-.>", vim.lsp.buf.code_action, "Acciones rapidas")
-- (vim.diagnostic.jump es de nvim 0.11; en 0.10 se usa goto_next/goto_prev)
local function diag(n)
  return function()
    if vim.diagnostic.jump then vim.diagnostic.jump({ count = n, float = true })
    elseif n > 0 then vim.diagnostic.goto_next({ float = true })
    else vim.diagnostic.goto_prev({ float = true }) end
  end
end
map("n", "<F8>", diag(1), "Siguiente problema")
map("n", "<S-F8>", diag(-1), "Problema anterior")
map({ "n", "v" }, "<S-A-f>", function() require("conform").format({ lsp_format = "fallback" }) end, "Formatear")

-- Opciones rapidas
map("n", "<leader>un", function() vim.opt.relativenumber = not vim.opt.relativenumber:get() end, "Numeros relativos")
map("n", "<leader>uw", function() vim.opt.wrap = not vim.opt.wrap:get() end, "Ajuste de linea")
