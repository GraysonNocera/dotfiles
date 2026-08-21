return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- razzmatazz/csharp-language-server (binary: csharp-ls), installed as a
        -- dotnet global tool -> lives on PATH at ~/.dotnet/tools/csharp-ls.
        -- Chosen over roslyn.nvim: much lighter, and it starts/stops fast, so
        -- there's no slow-shutdown stall to work around (see the removed
        -- FastQuit command in config/autocmds.lua).
        csharp_ls = {
          mason = false, -- provided by `dotnet tool install --global csharp-ls`
          -- Razor/.cshtml support is opt-in and experimental in csharp-ls; the
          -- `--features razor-support` flag turns it on (equivalent to the
          -- csharp.razorSupport setting). nvim already detects .razor/.cshtml
          -- as filetype "razor", so we just add it to filetypes to attach.
          cmd = { "csharp-ls", "--features", "razor-support" },
          filetypes = { "cs", "razor" },
          on_attach = function(_, bufnr)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename (LSP)" })
          end,
        },
      },
    },
  },
}
