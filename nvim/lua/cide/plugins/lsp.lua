-- clangd language server + autocompletion.
return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    lazy = false,
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = "rounded" } },
        menu = { border = "rounded" },
        list = { selection = { preselect = true, auto_insert = false } },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    config = function(_, opts)
      require("blink.cmp").setup(opts)
      -- Same flags as the VS Code clangd setup
      vim.lsp.config("clangd", {
        cmd = {
          "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed",
          "--header-insertion=iwyu", "--fallback-style=llvm", "-j=2",
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        -- Used for files without compile_commands.json (e.g. a lone main.c)
        init_options = { fallbackFlags = { "-Wall", "-Wextra" } },
        root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", "CMakeLists.txt", "Makefile", ".git" },
        capabilities = require("blink.cmp").get_lsp_capabilities({
          offsetEncoding = { "utf-16" },
        }),
      })
      vim.lsp.enable("clangd")

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buf = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
          end
          local tb = function(picker) return "<Cmd>Telescope " .. picker .. "<CR>" end

          -- VS Code keys
          map("n", "<F12>", vim.lsp.buf.definition, "Go to definition")
          map("n", "<S-F12>", tb("lsp_references"), "Find references")
          map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")
          map({ "n", "v" }, "<C-.>", vim.lsp.buf.code_action, "Quick fix")
          map({ "n", "v", "i" }, "<S-A-f>", function() vim.lsp.buf.format() end, "Format document")
          map("n", "<A-o>", "<Cmd>LspClangdSwitchSourceHeader<CR>", "Switch header/source")

          -- Vim-style keys
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gr", tb("lsp_references"), "References")
          map("n", "gi", tb("lsp_implementations"), "Implementations")
          map("n", "K", function() vim.lsp.buf.hover({ border = "rounded" }) end, "Hover info")
          map("i", "<C-k>", function() vim.lsp.buf.signature_help({ border = "rounded" }) end, "Signature help")
          map("n", "<leader>lr", vim.lsp.buf.rename, "Rename")
          map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>lf", function() vim.lsp.buf.format() end, "Format")
          map("n", "<leader>lo", "<Cmd>LspClangdSwitchSourceHeader<CR>", "Switch header/source")

          if client and client:supports_method("textDocument/documentHighlight") then
            local hl_group = vim.api.nvim_create_augroup("cide-lsp-highlight-" .. buf, { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = hl_group, buffer = buf, callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = hl_group, buffer = buf, callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      vim.api.nvim_create_user_command("LspClangdSwitchSourceHeader", function()
        local buf = vim.api.nvim_get_current_buf()
        local client = vim.lsp.get_clients({ bufnr = buf, name = "clangd" })[1]
        if not client then return vim.notify("clangd is not running", vim.log.levels.WARN) end
        client:request("textDocument/switchSourceHeader", vim.lsp.util.make_text_document_params(buf),
          function(err, result)
            if err or not result then return vim.notify("No matching header/source", vim.log.levels.INFO) end
            vim.cmd.edit(vim.uri_to_fname(result))
          end, buf)
      end, { desc = "Switch between .c and .h" })
    end,
  },
}
