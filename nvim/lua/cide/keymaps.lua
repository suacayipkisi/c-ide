-- VS Code style shortcuts on top of normal Vim motions.
-- Plugin-specific keys live next to their plugin in lua/cide/plugins/.
local map = vim.keymap.set

-- Save (Ctrl+S) in every mode
map({ "n", "i", "v" }, "<C-s>", "<Cmd>silent! wall<CR><Esc>", { desc = "Save all" })

-- Copy / cut / paste like VS Code, through the system clipboard ('clipboard' is unnamedplus).
-- Without a selection, copy and cut take the whole line. Ctrl+C in the terminal panel is
-- left alone so it still stops a running program.
map("v", "<C-c>", "y", { desc = "Copy" })
map("v", "<C-x>", "d", { desc = "Cut" })
map("v", "<C-v>", '"_dP', { desc = "Paste over selection" })
map("n", "<C-c>", "yy", { desc = "Copy line" })
map("n", "<C-x>", "dd", { desc = "Cut line" })
map("n", "<C-v>", "P", { desc = "Paste" })
map("i", "<C-c>", "<C-o>yy", { desc = "Copy line" })
map("i", "<C-x>", "<C-o>dd", { desc = "Cut line" })
map("i", "<C-v>", "<C-r><C-o>+", { desc = "Paste" })
map("c", "<C-v>", "<C-r>+", { desc = "Paste" })
-- Vim's block (column) selection moves from Ctrl+V to Alt+V
map("n", "<A-v>", "<C-v>", { desc = "Block (column) selection" })

-- Undo like VS Code. Ctrl+Z would otherwise suspend Neovim, which freezes a foot window.
map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("v", "<C-z>", "<Esc>u", { desc = "Undo" })
map("o", "<C-z>", "<Esc>", { desc = "Cancel" })

-- Clear search highlight
map("n", "<Esc>", "<Cmd>nohlsearch<CR>")

-- Toggle comment (Ctrl+/ ; most terminals send it as Ctrl+_)
map("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment" })
map("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment" })
map("v", "<C-/>", "gc", { remap = true, desc = "Toggle comment" })
map("v", "<C-_>", "gc", { remap = true, desc = "Toggle comment" })
map("i", "<C-/>", "<Esc>gcca", { remap = true, desc = "Toggle comment" })
map("i", "<C-_>", "<Esc>gcca", { remap = true, desc = "Toggle comment" })

-- Move lines (Alt+Up / Alt+Down)
map("n", "<A-Down>", "<Cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-Up>", "<Cmd>m .-2<CR>==", { desc = "Move line up" })
map("i", "<A-Down>", "<Esc><Cmd>m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<A-Up>", "<Esc><Cmd>m .-2<CR>==gi", { desc = "Move line up" })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- Duplicate line (Shift+Alt+Down)
map("n", "<S-A-Down>", "<Cmd>t.<CR>", { desc = "Duplicate line" })
map("v", "<S-A-Down>", ":t'><CR>gv", { desc = "Duplicate selection", silent = true })

-- Keep selection while indenting
map("v", "<", "<gv")
map("v", ">", ">gv")
map("v", "<Tab>", ">gv")
map("v", "<S-Tab>", "<gv")

-- Window navigation: Alt+h/j/k/l (also works from inside the terminal)
for _, mode in ipairs({ "n", "t" }) do
  map(mode, "<A-h>", "<Cmd>wincmd h<CR>", { desc = "Window left" })
  map(mode, "<A-j>", "<Cmd>wincmd j<CR>", { desc = "Window down" })
  map(mode, "<A-k>", "<Cmd>wincmd k<CR>", { desc = "Window up" })
  map(mode, "<A-l>", "<Cmd>wincmd l<CR>", { desc = "Window right" })
end

-- Split editor (Ctrl+\ like VS Code)
map("n", "<C-\\>", "<Cmd>vsplit<CR>", { desc = "Split editor right" })

-- Leave terminal mode with Esc Esc
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Buffers (= editor tabs)
map("n", "<leader>q", function()
  local buf = vim.api.nvim_get_current_buf()
  vim.cmd("bprevious")
  vim.cmd("bdelete " .. buf)
end, { desc = "Close tab" })
local function quit_ide()
  if vim.fn.confirm("Quit C IDE?", "&Yes\n&No", 2) == 1 then
    vim.cmd("silent! wall")
    vim.cmd("qa")
  end
end
map("n", "<leader>Q", quit_ide, { desc = "Quit IDE (asks first)" })
map({ "n", "i", "v" }, "<C-q>", quit_ide, { desc = "Quit IDE (asks first)" })

-- Diagnostics (F8 / Shift+F8 like VS Code)
map("n", "<F8>", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next problem" })
map("n", "<S-F8>", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous problem" })
map("n", "<leader>le", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

-- UI toggles
local toggles = require("cide.toggles")
map("n", "<leader>uc", toggles.toggle_syntax, { desc = "Toggle code coloring" })
map("n", "<F7>", toggles.toggle_syntax, { desc = "Toggle code coloring" })
map("n", "<leader>uh", toggles.toggle_hints, { desc = "Toggle inlay hints (permanent)" })
map("n", "<leader>uw", "<Cmd>set wrap!<CR>", { desc = "Toggle word wrap" })
map("n", "<leader>un", "<Cmd>set relativenumber!<CR>", { desc = "Toggle relative numbers" })
-- Ctrl+Alt+H shows parameter names until the cursor moves (VS Code's Ctrl+Alt hold).
-- <M-BS> is what Ctrl+Alt+H looks like in terminals without the kitty keyboard protocol.
map({ "n", "i" }, "<C-A-h>", toggles.peek_hints, { desc = "Peek inlay hints" })
map("n", "<M-BS>", toggles.peek_hints, { desc = "Peek inlay hints" })

-- Build & run (F5) and help
map({ "n", "i" }, "<F5>", function() require("cide.runner").run() end, { desc = "Build & run" })
map("n", "<leader>r", function() require("cide.runner").run() end, { desc = "Build & run" })
map("n", "<leader>R", function() require("cide.runner").build_only() end, { desc = "Build only" })
map("n", "<leader>h", function()
  vim.cmd("vsplit " .. vim.fn.stdpath("config") .. "/CHEATSHEET.md")
  vim.bo.readonly = true
end, { desc = "Open cheat sheet" })
