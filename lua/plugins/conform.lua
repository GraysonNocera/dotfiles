return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      cs = { "csharpier" },
      go = { "goimports", "gofumpt" },
      yaml = { "yamlfmt" },
      json = { "jq" },
      jsonc = { "jq" },
    },
    formatters = {
      -- retain_line_breaks keeps the blank lines I use to separate jobs;
      -- without it yamlfmt collapses them on save.
      yamlfmt = {
        prepend_args = { "-formatter", "retain_line_breaks=true" },
      },
    },
  },
}
