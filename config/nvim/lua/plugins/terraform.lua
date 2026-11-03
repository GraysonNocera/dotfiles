-- Terraform provider development. The bulk of the setup (terraformls, tflint,
-- treesitter parsers, terraform_fmt, the telescope pickers) comes from
-- lazyvim.plugins.extras.lang.terraform; this file only adds what that misses.

-- `.tfvars` already maps to terraform-vars, but the example files checked into
-- provider repos carry a suffix, so they'd otherwise open as plain text.
vim.filetype.add({
  pattern = {
    [".*%.tfvars%.example"] = "terraform-vars",
    [".*%.tfvars%.tmpl"] = "terraform-vars",
  },
})

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        terraformls = {
          -- terraform-ls ignores workspace/didChangeConfiguration, so these have
          -- to ride along on the initialize call rather than going in `settings`.
          init_options = {
            experimentalFeatures = {
              -- Fill in a resource's required attributes when completing it,
              -- which is most of the value when writing configs against a
              -- provider whose schema you're still changing.
              prefillRequiredFields = true,
              validateOnSave = true,
            },
          },
        },
      },
    },
  },
}
