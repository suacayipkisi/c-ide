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

-- Closing the last editor window (:q, ZZ, Ctrl+W q, ...) closes the file, not the IDE:
-- if only side panels (explorer, terminal, debug UI) are left, open an empty editor again.
local function is_editor_win(win)
  local buf = vim.api.nvim_win_get_buf(win)
  return vim.api.nvim_win_get_config(win).relative == "" and vim.bo[buf].buftype == ""
    and not vim.bo[buf].filetype:match("^neo%-tree")
end

local function tree_width()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "neo-tree" then
      return vim.api.nvim_win_get_width(w)
    end
  end
end

vim.api.nvim_create_autocmd("WinClosed", {
  group = group,
  callback = function()
    -- WinClosed runs before the layout changes, so this is the width the user had
    local width_before = tree_width()
    vim.schedule(function()
      if vim.v.exiting ~= vim.NIL then return end
      local wins = vim.tbl_filter(function(w)
        return vim.api.nvim_win_get_config(w).relative == ""
      end, vim.api.nvim_list_wins())
      if #wins == 0 or vim.iter(wins):any(is_editor_win) then return end

      local tree = vim.iter(wins):find(function(w)
        return vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "neo-tree"
      end)
      if tree then
        vim.api.nvim_set_current_win(tree)
        vim.cmd("rightbelow vnew")
        vim.api.nvim_win_set_width(tree, width_before or 30)
      else
        local panel = wins[1]
        local height = vim.api.nvim_win_get_height(panel)
        vim.api.nvim_set_current_win(panel)
        vim.cmd("topleft new")
        vim.api.nvim_win_set_height(panel, math.min(height, 14))
        vim.cmd("wincmd t")
      end
    end)
  end,
})

-- Black box: remember the last keys pressed and write them out when Neovim exits,
-- so an unexpected quit can be traced back to the key that caused it.
local recent_keys = {}
vim.on_key(function(_, typed)
  if typed and typed ~= "" then
    table.insert(recent_keys, ("%s %s"):format(vim.api.nvim_get_mode().mode, vim.fn.keytrans(typed)))
    if #recent_keys > 80 then table.remove(recent_keys, 1) end
  end
end, vim.api.nvim_create_namespace("cide-black-box"))

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = function()
    local lines = { "# C IDE exited at " .. os.date("%Y-%m-%d %H:%M:%S"), "# mode key (oldest first)" }
    vim.list_extend(lines, recent_keys)
    pcall(vim.fn.writefile, lines, vim.fn.stdpath("state") .. "/cide-last-keys.log")
  end,
})

-- Reload files changed outside the editor
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = group,
  command = "silent! checktime",
})
