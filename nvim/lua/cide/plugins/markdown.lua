-- Markdown preview: rendered inside the editor, or live in the browser.
return {
  -- In-editor rendering (headings, tables, code blocks, checkboxes).
  -- The cursor line and insert mode always show the raw text.
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<C-S-v>", "<Cmd>RenderMarkdown toggle<CR>", ft = "markdown", desc = "Toggle markdown preview" },
      { "<leader>mp", "<Cmd>RenderMarkdown toggle<CR>", ft = "markdown", desc = "Toggle preview (in editor)" },
    },
    opts = {
      completions = { blink = { enabled = true } },
      heading = { sign = false, width = "block", left_pad = 1, right_pad = 2 },
      code = { sign = false, width = "block", left_pad = 1, right_pad = 2, border = "thin" },
      pipe_table = { preset = "round" },
    },
  },

  -- Live browser preview with scroll sync and images (like VS Code's side preview)
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    build = "cd app && npm install --no-fund --no-audit",
    init = function()
      vim.g.mkdp_theme = "dark"
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_page_title = "${name}"
      vim.g.mkdp_echo_preview_url = 1
    end,
    keys = {
      { "<leader>mb", "<Cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "Toggle preview (browser)" },
    },
  },
}
