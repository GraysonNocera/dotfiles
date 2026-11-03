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
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      explorer = {
        focus = "center",
      },

      -- Explorer is a picker in disguise; its filters live here. `hidden`
      -- (dotfiles) and `ignored` (git-ignored / VC-untracked-ignored) are
      -- separate toggles, both off by default — which is why ignored files
      -- vanish entirely. Turn both on so nothing is hidden. Toggle live in
      -- the explorer with `H` (hidden) and `I` (ignored).
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
          },
        },
      },

      -- disable the tab/buffer UI
      bufferline = { enabled = false },
    },
  },
}
