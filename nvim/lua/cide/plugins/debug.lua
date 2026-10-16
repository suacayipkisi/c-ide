-- Debugger: gdb's built-in DAP mode (gdb >= 14) + a VS Code like UI.
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      { "theHamsta/nvim-dap-virtual-text", opts = { virt_text_pos = "eol" } },
    },
    keys = {
      { "<F6>", function() require("dap").continue() end, desc = "Debug: start / continue" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Step out" },
      { "<S-F5>", function() require("dap").terminate() end, desc = "Stop debugging" },
      { "<leader>dd", function() require("dap").continue() end, desc = "Start / continue" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      {
        "<leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end,
        desc = "Conditional breakpoint",
      },
      { "<leader>dn", function() require("dap").step_over() end, desc = "Step over (next)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dc", function() require("dap").run_to_cursor() end, desc = "Run to cursor" },
      { "<leader>dq", function() require("dap").terminate() end, desc = "Stop" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Evaluate expression" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      dap.listeners.after.event_initialized["cide"] = function() dapui.open() end
      dap.listeners.before.event_terminated["cide"] = function() dapui.close() end
      dap.listeners.before.event_exited["cide"] = function() dapui.close() end

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })

      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }

      local config = {
        {
          name = "Build & debug",
          type = "gdb",
          request = "launch",
          program = function()
            local program = require("cide.runner").build_for_debug()
            return program or dap.ABORT
          end,
          cwd = function() return vim.fs.dirname(vim.api.nvim_buf_get_name(0)) end,
          stopAtBeginningOfMainSubprogram = false,
        },
      }
      dap.configurations.c = config
      dap.configurations.cpp = config
    end,
  },
}
