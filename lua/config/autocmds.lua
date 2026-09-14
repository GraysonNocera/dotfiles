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

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc" },
  callback = function()
    vim.bo.equalprg = "jq ."
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function()
    -- NOTE: retain_line_breaks=true is intentionally omitted. It makes yamlfmt
    -- inject a #magic___^_^___line sentinel that corrupts literal block scalars
    -- (`run: |`) into one-line double-quoted strings. Plain yamlfmt on manual `=`
    -- keeps block scalars intact (it does collapse blank-line separators).
    vim.bo.equalprg = "yamlfmt -in"
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

-- Auto-reload buffers that changed on disk (e.g. an AI agent editing many files
-- at once). LazyVim only runs `checktime` on FocusGained/TermClose/TermLeave,
-- and FocusGained rarely reaches nvim through tmux, so also check when idle
-- (CursorHold fires after `updatetime`, 200ms) and on buffer switch. Roslyn
-- trusts the buffer text it was sent, so a stale buffer means stale analysis;
-- the reload resends the document. Buffers with unsaved local edits are left
-- alone and reported, exactly as `:e` would. Manual fallback: <leader>br.
vim.api.nvim_create_autocmd(
  { "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose", "TermLeave" },
  {
    group = vim.api.nvim_create_augroup("checktime_agent_edits", { clear = true }),
    callback = function()
      if vim.fn.mode() ~= "c" and vim.o.buftype == "" then
        -- Neovim defers timestamp checks while an autocmd is running, so run
        -- it on the next loop tick instead of relying on the deferred retry.
        vim.schedule(function()
          vim.cmd("checktime")
        end)
      end
    end,
  }
)

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = vim.api.nvim_create_augroup("checktime_agent_edits_notify", { clear = true }),
  callback = function(args)
    vim.notify("Reloaded " .. vim.fn.fnamemodify(args.file, ":~:."), vim.log.levels.INFO)
  end,
})

-- Roslyn: wipe source-generated buffers as soon as they are hidden. While one
-- is open, Roslyn "freezes" that generated document in its workspace, and its
-- rename handler asserts that only Razor documents are ever frozen
-- (ProtocolConversions.cs: "Unexpected false"), so every rename in the
-- solution fails until the buffer is closed. roslyn.nvim opens these via
-- BufReadCmd (`gd` into generated code), so BufEnter is the safe hook here.
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("roslyn_source_generated_wipe", { clear = true }),
  pattern = "roslyn-source-generated://*",
  callback = function(args)
    vim.bo[args.buf].bufhidden = "wipe"
  end,
})
