return {
  "seblyng/roslyn.nvim",
  opts = {
    on_attach = function(client, bufnr)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr })
    end,
  },
}
