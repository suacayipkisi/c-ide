-- C IDE: a keyboard-first, VS Code (Dark Modern) flavored Neovim setup.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("cide.options")
require("cide.keymaps")
require("cide.autocmds")

-- Bootstrap lazy.nvim (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("cide.plugins", {
  install = { colorscheme = { "vscode" } },
  checker = { enabled = false },
  change_detection = { notify = false },
  ui = { border = "rounded" },
})
