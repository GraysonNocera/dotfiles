return {
  "seblyng/roslyn.nvim",
  opts = {
    -- Let Roslyn watch files itself instead of registering thousands of
    -- libuv fs_event handles through Neovim. With the default "auto", those
    -- handles are cancelled synchronously on the main loop at stop/restart
    -- (`_watchfiles.cancel()`), which is the ~45s :lsp restart freeze — and
    -- the same stall FastQuit works around. "roslyn" => dynamicRegistration
    -- off, so there's nothing for Neovim to unwind; Roslyn uses FSEvents.
    filewatching = "roslyn",
    on_attach = function(client, bufnr)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr })
    end,
  },
}
