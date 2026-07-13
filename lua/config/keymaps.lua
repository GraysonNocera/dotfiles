-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap
local fn = vim.fn

map.set("n", "<leader>o", function()
  fn.jobstart({ "open", vim.fn.expand("%:h") }, { detach = true })
end, { desc = "Open dir in Finder" })

map.set("n", "<C-d>", "<C-d>zz")
map.set("n", "<C-u>", "<C-u>zz")

-- Removing Lazy defaults
map.del("n", "<leader>l")
-- map.del("n", "<leader>ff")
-- map.del("n", "<leader>fF")

map.set("n", "<leader>p", "<cmd>Lazy<cr>", { desc = "Plugins (Lazy)" })

-- LSP Stuff
map.set("n", "<leader>l", "", { desc = "LSP" })
map.set("n", "<leader>li", "<cmd>checkhealth vim.lsp<cr>", { desc = "LSP: Info" })
map.set("n", "<leader>lr", "<cmd>lsp restart<cr>", { desc = "LSP: Restart" })
map.set("n", "<leader>ls", "<cmd>lsp enable<cr>", { desc = "LSP: Start" })
map.set("n", "<leader>lx", "<cmd>lsp disable<cr>", { desc = "LSP: Stop" })

map.set("n", "<leader>nn", function()
  require("telescope").extensions.notify.notify()
end, { desc = "Show Notifications" })

map.set("n", "<leader>nc", function()
  require("notify").clear_history()
end, { desc = "Clear Notification History " })

-- Telescope weirdness
-- map.set("n", "<leader>ff", function()
--   require("telescope.builtin").find_files()
-- end, { desc = "Find Files (Root Dir)" })
-- map.set("n", "<leader>fF", function()
--   require("telescope.builtin").find_files({
--     cwd = require("lazyvim.util").root(),
--   })
-- end, { desc = "Find Files (cwd)" })

-- Markdown
map.set("n", "<leader>m", "", { desc = "Markdown" })

-- Harpoon
local harpoon = require("harpoon")
harpoon:setup()

map.set("n", "<leader>a", function()
  harpoon:list():add()
end)
map.set("n", "<C-e>", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)

map.set("n", "<C-m>", function()
  harpoon:list():select(1)
end)
map.set("n", "<C-t>", function()
  harpoon:list():select(2)
end)
map.set("n", "<C-n>", function()
  harpoon:list():select(3)
end)
map.set("n", "<C-s>", function()
  harpoon:list():select(4)
end)

-- Easy Dotnet
local dotnet = require("easy-dotnet")

map.set("n", "<leader>d", function() end, { desc = ".NET" })
map.set("n", "<leader>dr", function()
  dotnet.run()
end, { desc = ".NET Run project" })

map.set("n", "<leader>dd", function()
  dotnet.debug()
end, { desc = ".NET Debug project" })

map.set("n", "<leader>db", function()
  dotnet.build()
end, { desc = ".NET Build project" })

map.set("n", "<leader>dt", function()
  dotnet.test()
end, { desc = ".NET Run tests" })

map.set("n", "<leader>dT", function()
  dotnet.testrunner()
end, { desc = ".NET Test runner UI" })

map.set("n", "<leader>ds", function()
  dotnet.restore()
end, { desc = ".NET Restore" })

map.set("n", "<leader>dv", function()
  dotnet.project_view()
end, { desc = ".NET Project view" })

map.set("n", "<leader>dc", function()
  dotnet.clean()
end, { desc = ".NET Clean" })

map.set("n", "<leader>de", function() end, { desc = ".NET EF Migrations" })

map.set("n", "<leader>del", function()
  dotnet.ef_migrations_list()
end, { desc = ".NET EF Migrations List" })

map.set("n", "<leader>dea", function()
  vim.ui.input({ prompt = "Migration name: " }, function(name)
    if not name or name == "" then
      return
    end
    dotnet.ef_migrations_add(name)
  end)
end, { desc = ".NET EF Migrations Add" })

map.set("n", "<leader>der", function()
  dotnet.ef_migrations_remove()
end, { desc = ".NET EF Migrations Remove" })

map.set("n", "<leader>dw", function()
  dotnet.watch()
end, { desc = ".NET Run Watch" })

-- Copilot
map.set("n", "<leader>co", function()
  require("CopilotChat").toggle()
end, { desc = "Toggle CopilotChat" })
