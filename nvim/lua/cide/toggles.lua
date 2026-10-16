-- UI toggles: syntax coloring and inlay hints.
local M = {}

M.syntax_enabled = true

local function code_buffers()
  return vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == ""
  end, vim.api.nvim_list_bufs())
end

-- Turns all code coloring (treesitter, LSP semantic tokens, regex syntax) on or off.
-- UI colors (explorer, tabs, diagnostics) are not affected.
function M.set_syntax(enabled)
  M.syntax_enabled = enabled
  vim.cmd(enabled and "syntax on" or "syntax off")
  for _, buf in ipairs(code_buffers()) do
    if enabled then
      pcall(vim.treesitter.start, buf)
    else
      pcall(vim.treesitter.stop, buf)
    end
  end
  vim.lsp.semantic_tokens.enable(enabled)
  vim.notify("Syntax coloring " .. (enabled and "on" or "off"))
end

function M.toggle_syntax()
  M.set_syntax(not M.syntax_enabled)
end

-- Permanent inlay hints toggle for the current buffer.
function M.toggle_hints()
  local filter = { bufnr = 0 }
  local enabled = not vim.lsp.inlay_hint.is_enabled(filter)
  vim.lsp.inlay_hint.enable(enabled, filter)
  vim.notify("Inlay hints " .. (enabled and "on" or "off"))
end

-- VS Code "offUnlessPressed": show parameter names until the cursor moves or you type.
-- Terminals cannot report a held Ctrl+Alt on its own, so a key press shows the hints
-- and the next movement hides them (holding the key keeps them visible).
local peek_group = vim.api.nvim_create_augroup("cide-hint-peek", { clear = true })

function M.peek_hints()
  local buf = vim.api.nvim_get_current_buf()
  if vim.lsp.inlay_hint.is_enabled({ bufnr = buf }) and not M.peeking then
    return -- permanently on, nothing to peek
  end
  M.peeking = true
  vim.lsp.inlay_hint.enable(true, { bufnr = buf })

  vim.api.nvim_clear_autocmds({ group = peek_group })
  -- Arm on the next tick so the triggering key itself does not hide the hints
  vim.schedule(function()
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter", "TextChanged", "BufLeave" }, {
      group = peek_group,
      once = true,
      callback = function()
        M.peeking = false
        if vim.api.nvim_buf_is_valid(buf) then
          vim.lsp.inlay_hint.enable(false, { bufnr = buf })
        end
      end,
    })
  end)
end

return M
