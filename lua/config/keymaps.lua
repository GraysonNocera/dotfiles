-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap

map.set("n", "gp", function()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result)
    if result and result[1] then
      vim.lsp.util.preview_location(result[1])
    end
  end)
end, { desc = "Peek Definition" })

map.del("n", "<leader>l") -- remove Lazy default
map.set("n", "<leader>p", "<cmd>Lazy<cr>", { desc = "Plugins (Lazy)" })

-- LSP Stuff
map.set("n", "<leader>l", "", { desc = "LSP" })
map.set("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP: Info" })
map.set("n", "<leader>lr", "<cmd>LspRestart<cr>", { desc = "LSP: Restart" })
map.set("n", "<leader>ls", "<cmd>LspStart<cr>", { desc = "LSP: Start" })
map.set("n", "<leader>lx", "<cmd>LspStop<cr>", { desc = "LSP: Stop" })

-- Markdown
map.set("n", "<leader>m", "", { desc = "Markdown" })
map.set("n", "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle Markdown Render" })
