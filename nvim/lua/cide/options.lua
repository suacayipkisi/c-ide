local o = vim.opt

-- Mouse works everywhere, but nothing requires it
o.mouse = "a"
o.mousemoveevent = true
o.clipboard = "unnamedplus"

-- Line numbers: absolute on the current line, relative elsewhere (great for 5j / 12k jumps)
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true

-- Mirrors VS Code settings: tabSize 2, wordWrap on
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.expandtab = true
o.smartindent = true
o.wrap = true
o.linebreak = true
o.breakindent = true

o.ignorecase = true
o.smartcase = true
o.inccommand = "split"

o.termguicolors = true
o.laststatus = 3
o.showmode = false
o.splitright = true
o.splitbelow = true
o.scrolloff = 8
o.sidescrolloff = 8
o.updatetime = 250
o.timeoutlen = 400
o.undofile = true
o.swapfile = false
o.confirm = true
o.pumheight = 12
o.fillchars = { eob = " ", fold = " ", foldopen = "\u{f078}", foldclose = "\u{f054}", foldsep = " " }
o.list = true
o.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

-- Folding via treesitter (opened by default, toggle with za / zR / zM)
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99

vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "\u{f057} ",
      [vim.diagnostic.severity.WARN] = "\u{f071} ",
      [vim.diagnostic.severity.INFO] = "\u{f05a} ",
      [vim.diagnostic.severity.HINT] = "󰌵 ",
    },
  },
})
