local tailwindcss = require("lspconfig.configs.tailwindcss")

-- Unified LSP navigation for `gd`/`gr`: if the cursor is already sitting on the
-- symbol's definition, jump to its references; otherwise jump to the definition.
-- LSP has no "am I on the definition?" query, so we ask for the definition and
-- check whether the returned range covers the current cursor line in this buffer.
local function smart_lsp_nav()
  local builtin = require("telescope.builtin")
  local clients = vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" })
  if #clients == 0 then
    return builtin.lsp_definitions()
  end

  local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding)
  local cur_line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local cur_uri = vim.uri_from_bufnr(0)

  vim.lsp.buf_request_all(0, "textDocument/definition", params, function(results)
    local on_definition = false
    for _, res in pairs(results) do
      local result = res.result
      if result then
        local locs = vim.islist(result) and result or { result }
        for _, loc in ipairs(locs) do
          local uri = loc.uri or loc.targetUri
          local range = loc.range or loc.targetSelectionRange or loc.targetRange
          if uri == cur_uri and range and cur_line >= range.start.line and cur_line <= range["end"].line then
            on_definition = true
            break
          end
        end
      end
      if on_definition then
        break
      end
    end

    vim.schedule(function()
      if on_definition then
        builtin.lsp_references()
      else
        builtin.lsp_definitions()
      end
    end)
  end)
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- -- Applies to every server: override LazyVim's default `gd`/`gr` so
        -- -- both run the smart def/refs toggle.
        -- ["*"] = {
        --   keys = {
        --     { "gd", smart_lsp_nav, desc = "Goto Definition / References (smart)" },
        --     { "gr", smart_lsp_nav, desc = "Goto Definition / References (smart)" },
        --   },
        -- },
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              staticcheck = true,
              completeUnimported = true,
              usePlaceholders = true,
              analyses = {
                unusedparams = true,
                nilness = true,
              },
            },
          },
        },
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
        -- Hugo layouts are `gohtmltmpl` (see config/gohtmltmpl.lua), not `html`.
        -- vscode-html-language-server still understands them, so keep tag and
        -- attribute completion working in shortcodes and partials.
        html = {
          filetypes = { "html", "gohtmltmpl" },
        },
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
