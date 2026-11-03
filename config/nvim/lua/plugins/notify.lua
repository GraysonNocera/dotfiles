return {
  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        -- Your optional nvim-notify configurations here
        stages = "fade",
        timeout = 3000,
      })
      -- Set nvim-notify as your default vim notifier
      vim.notify = require("notify")
    end,
  },
}
