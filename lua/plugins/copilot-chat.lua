return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      -- See Configuration section for options
      model = "claude-sonnet-4.6",
      window = {
        layout = "horizontal",
        height = 0.4,
      },
    },
  },
}
