return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      explorer = {
        focus = "center",
      },

      -- disable the tab/buffer UI
      bufferline = { enabled = false },
    },
  },
}
