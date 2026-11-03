return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      cs = { "csharpier" },
      elixir = { "mix_format" },
      heex = { "mix_format" },
      eelixir = { "mix_format" },
      go = { "goimports", "gofumpt" },
      -- yamlfmt disabled on save: with retain_line_breaks=true it injects a
      -- #magic___^_^___line sentinel that corrupts literal block scalars
      -- (`run: |`), collapsing multi-line GitHub Actions steps onto one line.
      -- Without that flag it collapses my blank-line separators instead, so
      -- there's no setting that's safe here. Format YAML manually if needed.
      -- yaml = { "yamlfmt" },
      json = { "jq" },
      jsonc = { "jq" },
    },
  },
}
