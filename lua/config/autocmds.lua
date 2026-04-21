-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
vim.api.nvim_create_autocmd("FileType", {
  pattern = "cs",
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle Markdown Render" })
  end,
})

-- -- Currently takes too long
-- vim.api.nvim_create_autocmd("BufWritePost", {
--   pattern = "*.cs",
--   command = "silent !dotnet csharpier format %",
-- })

-- local csharpier_running = false
-- local function should_run()
--   -- Must have dotnet
--   if vim.fn.executable("dotnet") == 0 then
--     return false
--   end
--
--   -- Must be a C# project
--   if vim.fn.glob("*.csproj") == "" then
--     return false
--   end
--
--   -- Must have csharpier installed (global or local tool)
--   local handle = io.popen("dotnet tool list -g 2>/dev/null | grep csharpier")
--   if handle then
--     local result = handle:read("*a")
--     handle:close()
--     if result == nil or result == "" then
--       return false
--     end
--   else
--     return false
--   end
--
--   return true
-- end
--
-- local function run_csharpier()
--   if csharpier_running then
--     return
--   end
--
--   if not should_run() then
--     return
--   end
--
--   csharpier_running = true
--
--   vim.system({ "dotnet", "csharpier", "format", "." }, { cwd = vim.fn.getcwd() }, function(obj)
--     csharpier_running = false
--
--     vim.schedule(function()
--       if obj.code == 0 then
--         vim.notify("CSharpier formatting complete", vim.log.levels.INFO)
--
--         -- Reload changed files
--         vim.cmd("checktime")
--       else
--         vim.notify("CSharpier failed", vim.log.levels.WARN)
--       end
--     end)
--   end)
-- end
--
-- vim.api.nvim_create_autocmd("TermOpen", {
--   pattern = "*lazygit",
--   callback = function()
--     run_csharpier()
--   end,
-- })
