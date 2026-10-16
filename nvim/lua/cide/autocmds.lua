local group = vim.api.nvim_create_augroup("cide", { clear = true })

-- Auto save (like VS Code "files.autoSave": "afterDelay")
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost", "BufLeave" }, {
  group = group,
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].modified and vim.bo[buf].buftype == "" and vim.bo[buf].modifiable
      and vim.api.nvim_buf_get_name(buf) ~= "" then
      vim.api.nvim_buf_call(buf, function() vim.cmd("silent! update") end)
    end
  end,
})

-- Treesitter highlighting (C, Lua, Markdown parsers ship with Neovim)
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(args)
    if require("cide.toggles").syntax_enabled then
      pcall(vim.treesitter.start, args.buf)
    end
  end,
})

-- Briefly flash yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})

-- Reopen files at the last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Reload files changed outside the editor
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = group,
  command = "silent! checktime",
})
