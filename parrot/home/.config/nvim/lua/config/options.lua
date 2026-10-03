local o = vim.opt

o.number = true
o.relativenumber = false     -- como VSCode (cambia con <Espacio>un)
o.mouse = "a"                -- raton en todo: clic, seleccion, rueda, arrastrar pestanas/separadores
o.mousemoveevent = true
o.clipboard = "unnamedplus"  -- el portapapeles del sistema (wl-copy)
o.undofile = true            -- deshacer persistente entre sesiones
o.swapfile = false
o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.incsearch = true
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true
o.wrap = false
o.scrolloff = 8
o.sidescrolloff = 8
o.signcolumn = "yes"
o.cursorline = true
o.termguicolors = true
o.splitright = true
o.splitbelow = true
o.updatetime = 250
o.timeoutlen = 400
o.showmode = false           -- el modo lo muestra la barra de estado
o.laststatus = 3             -- una sola barra de estado
o.cmdheight = 1
o.pumheight = 12
o.confirm = true             -- pregunta en vez de fallar al cerrar sin guardar
o.fillchars = { eob = " ", fold = " ", foldopen = "", foldclose = "", foldsep = " " }
o.foldlevel = 99
o.foldlevelstart = 99
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.list = true
o.listchars = { tab = "  ", trail = "·", nbsp = "␣" }
o.smoothscroll = true

-- Seleccion con Shift + flechas, como en VSCode (y escribir reemplaza lo seleccionado)
o.keymodel = "startsel,stopsel"
o.selectmode = "mouse,key"
o.selection = "exclusive"
