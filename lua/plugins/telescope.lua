return {
  "nvim-telescope/telescope.nvim",
  versio = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  keys = {
    { "<leader>fh", "<cmd>Telescope find_files hidden=true<cr>", desc = "Find Hidden Files" },
  },
}
