-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
-- Workaround for nvim 0.12.3 bug: document_color.lua:225 assert fails when LSP
-- client dies but the provider still holds its ID. Disable until upstream fix.
-- Guarded because the document_color API doesn't exist on all nvim versions.
if vim.lsp.document_color then
  vim.lsp.document_color.enable(false)
end

-- Quitting with a C# solution loaded is slow (~10s). Profiling showed the time
-- is NOT the Roslyn process (killing it doesn't help) — it's Neovim's own
-- teardown of many windows/buffers, plus `vim.lsp` client:stop() calling
-- `_watchfiles.cancel()` to unwind Roslyn's huge workspace file-watchers.
-- No autocmd can get ahead of the window teardown, so instead we persist
-- everything we care about and hard-exit the process, skipping teardown.
--
-- NOTE: we SIGKILL child pids directly rather than via client:stop(true),
-- because that LSP path (_watchfiles.cancel) is itself the ~10s stall.
vim.api.nvim_create_user_command("FastQuit", function()
  local uv = vim.uv or vim.loop
  pcall(function() vim.cmd("silent! wall") end) -- write all modified files
  pcall(function() require("persistence").save() end) -- keep the session
  pcall(function() vim.cmd("silent! wshada") end) -- keep marks/registers/history
  -- Delete swap files ourselves: SIGKILL skips nvim's normal exit cleanup,
  -- which is what usually unlinks them. Buffers are already written (wall
  -- above), so removing the swap is exactly what a clean exit would do —
  -- without this, every FastQuit orphans a .swp and re-open warns "swap
  -- file already exists".
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      local ok, swap = pcall(vim.fn.swapname, buf)
      if ok and swap ~= "" then
        pcall(uv.fs_unlink, swap)
      end
    end
  end
  -- Kill child processes (Roslyn, dotnet server) so they don't orphan.
  for _, pid in ipairs(vim.api.nvim_get_proc_children(vim.fn.getpid())) do
    pcall(uv.kill, pid, "sigkill")
  end
  uv.kill(vim.fn.getpid(), "sigkill") -- hard-exit, skipping the slow teardown
end, { desc = "Write everything, then hard-kill Neovim (instant quit)" })

-- Make the usual :wqa use the fast path (writes all + quits, same intent).
vim.cmd([[cnoreabbrev <expr> wqa (getcmdtype() == ':' && getcmdline() ==# 'wqa') ? 'FastQuit' : 'wqa']])

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc" },
  callback = function()
    vim.bo.equalprg = "jq ."
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function()
    -- retain_line_breaks keeps the blank lines I use to separate jobs;
    -- without it yamlfmt collapses them.
    vim.bo.equalprg = "yamlfmt -formatter retain_line_breaks=true -in"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "cs",
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
    -- Make `=` (e.g. gg=G) reindent/format C# through csharpier's stdin mode.
    vim.bo.equalprg = "dotnet csharpier format --stdin-path " .. vim.fn.shellescape(vim.fn.expand("%:p"))
    -- Don't format C# on save; use <leader>fl to run csharpier on demand.
    vim.b.autoformat = false
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
