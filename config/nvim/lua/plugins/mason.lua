return {
  "mason-org/mason.nvim",
  opts = {
    registries = {
      "github:mason-org/mason-registry",
      "github:Crashdummyy/mason-registry",
    },
    ensure_installed = {
      "yamlfmt",
      "gopls",
      "gofumpt",
      "goimports",
      "roslyn",
    },
  },
}
