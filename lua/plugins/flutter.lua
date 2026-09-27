-- Flutter/Dart: flutter-tools.nvim owns the Dart LSP (dartls), run/hot reload,
-- devices/emulators and debugging (via nvim-dap + `flutter debug-adapter`).
-- Don't also enable LazyVim's lang.dart extra — it starts a second dartls.
-- Saving a .dart file hot-reloads a running app; saving pubspec.yaml runs pub get.
-- Setup notes: ~/dev/game-app/docs/DEV_SETUP.md
local flutter_root = vim.fn.expand("~/development/flutter")

return {
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = { "dart" },
    cmd = { "FlutterRun", "FlutterDebug", "FlutterDevices", "FlutterEmulators" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
    keys = {
      { "<leader>F", "", desc = "+flutter" },
      { "<leader>Fr", "<cmd>FlutterRun<cr>", desc = "Run (debugger attached)" },
      { "<leader>Fq", "<cmd>FlutterQuit<cr>", desc = "Quit" },
      { "<leader>FR", "<cmd>FlutterRestart<cr>", desc = "Hot Restart" },
      { "<leader>Fh", "<cmd>FlutterReload<cr>", desc = "Hot Reload" },
      { "<leader>Fd", "<cmd>FlutterDevices<cr>", desc = "Pick Device" },
      { "<leader>Fe", "<cmd>FlutterEmulators<cr>", desc = "Launch Emulator/Simulator" },
      { "<leader>Fl", "<cmd>FlutterLogToggle<cr>", desc = "Toggle Dev Log" },
      { "<leader>FL", "<cmd>FlutterLogClear<cr>", desc = "Clear Dev Log" },
      { "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", desc = "Widget Outline" },
      { "<leader>Ft", "<cmd>FlutterDevTools<cr>", desc = "Start DevTools" },
      { "<leader>FT", "<cmd>FlutterOpenDevTools<cr>", desc = "Open DevTools in Browser" },
      { "<leader>Fp", "<cmd>FlutterPubGet<cr>", desc = "Pub Get" },
      { "<leader>Fc", "<cmd>FlutterCommands<cr>", desc = "All Commands" },
    },
    config = function()
      -- Intel (Rosetta) Homebrew's x86-only bash shadows /bin/bash on PATH, and
      -- Flutter's scripts use `#!/usr/bin/env bash`, so everything flutter spawns
      -- (xcodebuild included) would run under Rosetta. Prefer native bash for
      -- processes started from this nvim once a Dart file is opened.
      local shims = vim.fn.expand("~/development/flutter-bin/shims")
      if vim.fn.isdirectory(shims) == 1 and not vim.env.PATH:find(shims, 1, true) then
        vim.env.PATH = shims .. ":" .. vim.env.PATH
      end

      local ok, blink = pcall(require, "blink.cmp")
      require("flutter-tools").setup({
        -- Real SDK path (not the flutter-bin wrapper): the SDK root is derived from it.
        flutter_path = flutter_root .. "/bin/flutter",
        ui = { border = "rounded" },
        debugger = {
          enabled = true, -- :FlutterRun goes through nvim-dap, so breakpoints work
          exception_breakpoints = {}, -- don't pause on every caught exception
        },
        widget_guides = { enabled = true },
        closing_tags = { prefix = "// ", enabled = true },
        dev_log = {
          enabled = true,
          open_cmd = "botright 15split",
          focus_on_open = false,
        },
        lsp = {
          capabilities = ok and blink.get_lsp_capabilities() or nil,
          -- No `color` option: nvim 0.12 highlights LSP document colors natively.
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt",
            updateImportsOnRename = true,
            enableSnippets = true,
          },
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "dart" } },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        dart = { "dart_format" },
      },
    },
  },
}
