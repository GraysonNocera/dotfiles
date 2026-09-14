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

-- Reload every buffer whose file changed on disk (e.g. after an AI made edits
-- across many files). `:checktime` + autoread refreshes the unmodified ones so
-- the LSP stops diagnosing stale content; buffers with unsaved local changes
-- are left alone and reported instead of being clobbered.
map.set("n", "<leader>br", "<cmd>checktime<cr>", { desc = "Reload changed buffers" })

-- Removing Lazy defaults. Guarded: LazyVim no longer maps <leader>l by
-- default, and an unguarded del() throws E31 and aborts the rest of this file.
pcall(map.del, "n", "<leader>l")
-- map.del("n", "<leader>ff")
-- map.del("n", "<leader>fF")

map.set("n", "<leader>lz", "<cmd>Lazy<cr>", { desc = "Lazy (plugins)" })

-- Paste over a visual selection without clobbering the register with the
-- text that was replaced (delete to the black-hole register, then paste).
map.set("x", "<leader>p", '"_dP', { desc = "Paste (keep register)" })

-- Format on demand (csharpier for C#, conform formatters otherwise)
map.set({ "n", "v" }, "<leader>fl", function()
  require("conform").format({ async = true, lsp_format = "never" })
end, { desc = "Format buffer" })

-- Grep the visual selection across the project (not a file finder).
map.set("x", "<leader>l", function()
  -- Yank the selection into a scratch register, restoring the old value.
  local save = vim.fn.getreg("v")
  local save_type = vim.fn.getregtype("v")
  vim.cmd('noautocmd normal! "vy')
  local text = vim.fn.getreg("v")
  vim.fn.setreg("v", save, save_type)
  text = text:gsub("\n", "")
  require("telescope.builtin").grep_string({ search = text })
end, { desc = "Grep selection (project)" })

-- Scoped find / grep / explore for this multi-root repo.
--
-- The base keys (<leader>ff find, <leader>e explorer, ...) are pinned to the
-- repo top via vim.g.root_spec = { "cwd" } in options.lua, so they no longer
-- drift with the current buffer's project root. When you want to work inside
-- one subtree (.github/workflows, SSHManWeb, infrastructure/, ...) use the maps
-- below: each prompts for a folder (Tab-completes directories, defaults to the
-- current file's dir so it's one <cr> to pick "this folder") and scopes a
-- Snacks picker there. Empty input cancels.
local function in_folder(prompt, run)
  vim.ui.input({
    prompt = prompt,
    default = fn.expand("%:h") .. "/",
    completion = "dir",
  }, function(dir)
    if not dir or dir == "" then
      return
    end
    run(fn.fnamemodify(dir, ":p"))
  end)
end

-- Find files inside a folder you choose.
map.set("n", "<leader>fd", function()
  in_folder("Find files in folder: ", function(dir)
    Snacks.picker.files({ cwd = dir, title = "Files: " .. fn.fnamemodify(dir, ":~:.") })
  end)
end, { desc = "Find Files (in folder…)" })

-- Live-grep inside a folder you choose.
map.set("n", "<leader>sf", function()
  in_folder("Grep in folder: ", function(dir)
    Snacks.picker.grep({ cwd = dir, title = "Grep: " .. fn.fnamemodify(dir, ":~:.") })
  end)
end, { desc = "Search in folder (live grep)" })

-- Open the file explorer rooted at a folder you choose.
map.set("n", "<leader>ed", function()
  in_folder("Explore folder: ", function(dir)
    Snacks.explorer({ cwd = dir })
  end)
end, { desc = "Explorer (in folder…)" })

-- Git blame. <leader>gb now opens the whole-file blame in a scrollbound
-- gutter (Rider-style: author/date beside every line, via gitsigns). The old
-- per-line commit-log picker moves to <leader>gc. Both override the LazyVim
-- defaults (gb was Snacks git_log_line).
map.set("n", "<leader>gb", function()
  require("gitsigns").blame()
end, { desc = "Git Blame (file)" })
map.set("n", "<leader>gc", function()
  Snacks.picker.git_log_line()
end, { desc = "Git Blame Line (commits)" })

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

-- easy-dotnet has no project/solution explorer; `:Dotnet` with no args opens
-- a picker over every command it does provide.
map.set("n", "<leader>dv", function()
  vim.cmd("Dotnet")
end, { desc = ".NET Command picker" })

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
