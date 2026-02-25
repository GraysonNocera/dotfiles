return {
  "saghen/blink.cmp",
  dependencies = {
    {
      "giuxtaposition/blink-cmp-copilot",
    },
  },
  version = "*",
  opts = {
    keymap = {
      preset = "super-tab",
      ["<C-e>"] = {
        function(cmp)
          cmp.show()
        end,
      },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
    sources = {
      default = { "lsp", "easy-dotnet", "path", "copilot" },
      providers = {
        ["easy-dotnet"] = {
          name = "easy-dotnet",
          enabled = true,
          module = "easy-dotnet.completion.blink",
          score_offset = 10000,
          async = true,
        },
        copilot = {
          name = "copilot",
          module = "blink-cmp-copilot",
          score_offset = 100,
          async = true,
        },
      },
    },
  },
}
