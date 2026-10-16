-- Search, terminal, git, problems panel and editing helpers.
return {
  -- Fuzzy finder: Ctrl+P, Ctrl+Shift+F, command palette
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<C-p>", "<Cmd>Telescope find_files<CR>", desc = "Go to file" },
      { "<leader>ff", "<Cmd>Telescope find_files<CR>", desc = "Files" },
      { "<C-S-f>", "<Cmd>Telescope live_grep<CR>", desc = "Search in files" },
      { "<leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "Search text in files" },
      { "<leader>fw", "<Cmd>Telescope grep_string<CR>", desc = "Search word under cursor" },
      { "<C-f>", "<Cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Find in file" },
      { "<leader>fb", "<Cmd>Telescope buffers<CR>", desc = "Open tabs" },
      { "<leader>fr", "<Cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<leader>fs", "<Cmd>Telescope lsp_document_symbols<CR>", desc = "Symbols in file" },
      { "<leader>fS", "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "Symbols in project" },
      { "<leader>fk", "<Cmd>Telescope keymaps<CR>", desc = "Keyboard shortcuts" },
      { "<leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "Help" },
      { "<F1>", "<Cmd>Telescope commands<CR>", desc = "Command palette" },
      { "<C-S-p>", "<Cmd>Telescope commands<CR>", desc = "Command palette" },
    },
    opts = {
      defaults = {
        prompt_prefix = "\u{f002}  ",
        selection_caret = "\u{f054} ",
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top", width = 0.8, height = 0.8 },
        file_ignore_patterns = { "%.git/", "build/", "%.o$" },
      },
      pickers = {
        find_files = { hidden = true },
      },
    },
  },

  -- Integrated terminal (Ctrl+J / Ctrl+` like VS Code's panel)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-j>", "<Cmd>ToggleTerm direction=horizontal<CR>", mode = { "n", "i", "t" }, desc = "Toggle terminal" },
      { "<C-`>", "<Cmd>ToggleTerm direction=horizontal<CR>", mode = { "n", "i", "t" }, desc = "Toggle terminal" },
      { "<leader>tt", "<Cmd>ToggleTerm direction=horizontal<CR>", desc = "Terminal (bottom)" },
      { "<leader>tf", "<Cmd>2ToggleTerm direction=float<CR>", desc = "Terminal (floating)" },
      { "<leader>tv", "<Cmd>3ToggleTerm direction=vertical size=60<CR>", desc = "Terminal (right)" },
      {
        "<leader>gg",
        function()
          require("toggleterm.terminal").Terminal
            :new({ cmd = "lazygit", direction = "float", hidden = true, float_opts = { border = "rounded" } })
            :toggle()
        end,
        desc = "Lazygit",
      },
    },
    opts = {
      size = function(term)
        if term.direction == "vertical" then return math.floor(vim.o.columns * 0.4) end
        return 14
      end,
      shade_terminals = false,
      start_in_insert = true,
      persist_mode = false,
      float_opts = { border = "rounded" },
      highlights = { Normal = { guibg = "#181818" }, NormalFloat = { guibg = "#181818" } },
    },
  },

  -- Git line markers + hunks
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc }) end
        map("]h", function() gs.nav_hunk("next") end, "Next change")
        map("[h", function() gs.nav_hunk("prev") end, "Previous change")
        map("<leader>gp", gs.preview_hunk, "Preview change")
        map("<leader>gr", gs.reset_hunk, "Revert change")
        map("<leader>gb", gs.blame_line, "Blame line")
        map("<leader>gd", gs.diffthis, "Diff file")
      end,
    },
  },

  -- Problems panel (Ctrl+Shift+M)
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<C-S-m>", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Problems" },
      { "<leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Problems (project)" },
      { "<leader>xb", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Problems (this file)" },
      { "<leader>xq", "<Cmd>Trouble qflist toggle<CR>", desc = "Quickfix / build errors" },
      { "<leader>xs", "<Cmd>Trouble symbols toggle focus=false win.position=right<CR>", desc = "Outline" },
    },
  },

  -- Auto close brackets and quotes
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },

  -- Surround: ys{motion}{char}, cs"', ds(
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },

  -- Jump anywhere on screen with 2 keystrokes: press s, then the label
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { char = { enabled = false } } },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Jump (flash)" },
    },
  },
}
