return {
  "GustavEikaas/easy-dotnet.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    local dotnet = require("easy-dotnet")
    dotnet.setup({
      -- Silence easy-dotnet's vim.notify spinner entirely. It floods the
      -- screen with "<project> loaded" on startup and its `replace` logic
      -- errors with nvim-notify ("No matching notification found to replace")
      -- once a notification fades before the job finishes. Prewarming
      -- (background_scanning) stays on its default for performance.
      notifications = {
        handler = false,
      },
      lsp = {
        enabled = false,
      },
      test_runner = {
        viewmode = "float", -- nice floating test window
        enable_buffer_test_execution = true,
      },
    })
  end,
}
