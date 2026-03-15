return {
  "GustavEikaas/easy-dotnet.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    local dotnet = require("easy-dotnet")
    dotnet.setup({
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
