local tailwindcss = require("lspconfig.configs.tailwindcss")
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim" },
              },
            },
          },
        },
        gh_actions_ls = {},
        helm_ls = {
          settings = {
            ["helm-ls"] = {
              yamlls = {
                path = "yaml-language-server",
              },
            },
          },
        },
        jsonls = {
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
            },
          },
        },
        elixirls = {
          settings = {
            cmd = { "elixir-ls" }, -- Adjust path if not in your $PATH
            filetypes = { "elixir", "eelixir", "html-eex", "heex" },
            -- root_dir = require("lspconfig.util").root_dir("mix.exs", ".git"),
          },
        },
        tailwindcss = {
          settings = {
            filetypes = { "heex", "elixir", "html-eex" },
            init_options = {
              userLanguages = {
                heex = "html", -- Treat heex as html for tailwind
              },
            },
          },
        },
      },
    },
  },
}
