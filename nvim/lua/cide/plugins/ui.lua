-- Look & feel: VS Code "Dark Modern" theme, explorer, tabs, status bar.
return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Dark Modern palette on top of the Dark+ syntax colors
      require("vscode").setup({
        style = "dark",
        italic_comments = true,
        disable_nvimtree_bg = true,
        color_overrides = {
          vscBack = "#1F1F1F",
          vscTabCurrent = "#1F1F1F",
          vscTabOther = "#181818",
          vscTabOutside = "#181818",
          vscLeftDark = "#181818",
          vscLeftMid = "#1F1F1F",
          vscLeftLight = "#2B2B2B",
          vscPopupBack = "#202020",
          vscSplitDark = "#2B2B2B",
          vscSplitLight = "#2B2B2B",
          vscCursorDarkDark = "#222222",
          vscLineNumber = "#6E7681",
          vscSelection = "#264F78",
        },
        group_overrides = {
          CursorLineNr = { fg = "#CCCCCC" },
          WinSeparator = { fg = "#2B2B2B" },
          NormalFloat = { bg = "#202020" },
          FloatBorder = { fg = "#454545", bg = "#202020" },
          NeoTreeNormal = { bg = "#181818" },
          NeoTreeNormalNC = { bg = "#181818" },
          NeoTreeWinSeparator = { fg = "#2B2B2B", bg = "#181818" },
          NeoTreeCursorLine = { bg = "#04395E" },
          BufferLineIndicatorSelected = { fg = "#0078D4" },
          LspInlayHint = { fg = "#969696", bg = "#2A2A2A" },
        },
      })
      vim.cmd.colorscheme("vscode")

      -- Same italics as the VS Code tokenColorCustomizations
      local italic_groups = {
        "Comment", "@comment", "@keyword", "@keyword.conditional", "@keyword.repeat",
        "@keyword.return", "@keyword.modifier", "@keyword.type", "@keyword.directive",
        "@type.builtin", "@variable.parameter", "@lsp.type.parameter", "StorageClass",
        "Conditional", "Repeat", "Statement",
      }
      for _, name in ipairs(italic_groups) do
        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
        hl.italic = true
        vim.api.nvim_set_hl(0, name, hl)
      end
    end,
  },

  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- File explorer (Ctrl+B toggles, <leader>e focuses)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    lazy = false,
    keys = {
      { "<C-b>", "<Cmd>Neotree toggle reveal left<CR>", mode = { "n", "i" }, desc = "Toggle explorer" },
      { "<leader>e", "<Cmd>Neotree focus reveal left<CR>", desc = "Focus explorer" },
      { "<leader>ge", "<Cmd>Neotree float git_status<CR>", desc = "Git changed files" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        indent = { with_expanders = true },
        git_status = { symbols = { unstaged = "M", staged = "A", untracked = "U", added = "A", modified = "M" } },
      },
      window = {
        width = 30,
        mappings = {
          ["<Space>"] = "none",
          ["l"] = "open",
          ["h"] = "close_node",
          ["<Tab>"] = { "toggle_preview", config = { use_float = true } },
        },
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = "open_current",
        filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false },
      },
    },
  },

  -- Editor tabs
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<C-PageDown>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
      { "<C-PageUp>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous tab" },
      { "<S-l>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
      { "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous tab" },
      { "<leader>bp", "<Cmd>BufferLinePick<CR>", desc = "Pick tab" },
      { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "Close other tabs" },
      { "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", desc = "Tab 1" },
      { "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", desc = "Tab 2" },
      { "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", desc = "Tab 3" },
      { "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", desc = "Tab 4" },
      { "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", desc = "Tab 5" },
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        separator_style = "thin",
        hover = { enabled = true, delay = 150, reveal = { "close" } },
        close_command = function(n) vim.cmd("bprevious | bdelete " .. n) end,
        offsets = {
          { filetype = "neo-tree", text = "EXPLORER", text_align = "left", highlight = "NeoTreeNormal" },
        },
      },
    },
  },

  -- Status bar
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "vscode",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
        disabled_filetypes = { statusline = {} },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 }, "diagnostics" },
        lualine_x = { "lsp_status", "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { { "location", fmt = function(s) return "Ln " .. s:gsub(":", ", Col ") end } },
      },
      extensions = { "neo-tree", "toggleterm", "lazy", "trouble", "nvim-dap-ui", "quickfix" },
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    opts = { indent = { char = "│", highlight = "LineNr" }, scope = { enabled = false } },
  },

  -- Shows available keys after pressing <leader> (Space)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 300,
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>l", group = "code / lsp" },
        { "<leader>d", group = "debug" },
        { "<leader>g", group = "git" },
        { "<leader>b", group = "tabs" },
        { "<leader>x", group = "problems" },
        { "<leader>t", group = "terminal" },
        { "<leader>u", group = "ui toggles" },
        { "<leader>m", group = "markdown" },
      },
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = true }) end, desc = "All shortcuts" },
    },
  },
}
