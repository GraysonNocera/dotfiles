return {
  "saghen/blink.cmp",
  version = "*",
  config = function()
    local blink = require("blink.cmp")

    blink.setup({
      fuzzy = { implementation = "prefer_rust_with_warning" },

      keymap = {
        preset = "none",
      },

      sources = {
        default = { "lsp", "easy-dotnet", "path" },
        providers = {
          ["easy-dotnet"] = {
            name = "easy-dotnet",
            enabled = true,
            module = "easy-dotnet.completion.blink",
            score_offset = 10000,
            async = true,
          },
        },
      },
    })

    vim.keymap.set("i", "<Tab>", function()
      if blink.is_visible() then
        blink.accept()
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", true)
      end
    end, { silent = true })
  end,
}
