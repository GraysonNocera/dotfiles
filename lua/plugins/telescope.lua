return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "rcarriga/nvim-notify" },
  },
  keys = {
    { "<leader>fh", "<cmd>Telescope find_files hidden=true<cr>", desc = "Find Hidden Files" },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup({})

    -- Load the notify extension
    telescope.load_extension("notify")
  end,
}
