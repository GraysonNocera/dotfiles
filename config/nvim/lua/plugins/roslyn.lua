return {
  "seblyng/roslyn.nvim",
  opts = {
    -- Let Roslyn watch files itself instead of registering thousands of
    -- libuv fs_event handles through Neovim. With the default "auto", those
    -- handles are cancelled synchronously on the main loop at stop/restart
    -- (`_watchfiles.cancel()`), which is the ~45s :lsp restart freeze.
    -- "roslyn" => dynamicRegistration off, so there's nothing for Neovim to
    -- unwind; Roslyn uses FSEvents. (Quitting nvim with a solution loaded is
    -- still slow for other reasons — known, tolerated for now.)
    filewatching = "roslyn",
    on_attach = function(_, bufnr)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename (LSP)" })
    end,
  },
}
