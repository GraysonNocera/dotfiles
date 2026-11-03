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
-- trusts the buffer text it was sent, so a stale buffer means stale analysis.
-- See lua/config/reload.lua for why this isn't a plain `:checktime`. Buffers
-- with unsaved local edits are left alone and reported, exactly as `:e` would.
-- Manual fallback: <leader>br.
vim.api.nvim_create_autocmd(
  { "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose", "TermLeave" },
  {
    group = vim.api.nvim_create_augroup("checktime_agent_edits", { clear = true }),
    callback = function()
      -- Neovim defers timestamp checks while an autocmd is running, so run
      -- it on the next loop tick instead of relying on the deferred retry.
      vim.schedule(require("config.reload").reload)
    end,
  }
)

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

-- Gitsigns blame panel (<leader>gb): `y` yanks the full commit hash of the
-- line under the cursor. The panel only prints an abbreviated hash, and only
-- on the first line of each commit's block. The panel is scrollbound to the
-- source window, so its line numbers match the file's; ask `git blame` for
-- that one line rather than parsing the panel text.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("gitsigns_blame_yank_sha", { clear = true }),
  pattern = "gitsigns-blame",
  callback = function(args)
    vim.keymap.set("n", "y", function()
      local lnum = vim.api.nvim_win_get_cursor(0)[1]
      local file
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if buf ~= args.buf and vim.wo[win].scrollbind and vim.bo[buf].buftype == "" then
          file = vim.api.nvim_buf_get_name(buf)
          break
        end
      end
      if not file or file == "" then
        return vim.notify("Blame: source window not found", vim.log.levels.WARN)
      end
      local out = vim
        .system({ "git", "blame", "-l", "-s", "-L", lnum .. "," .. lnum, "--", file }, { cwd = vim.fs.dirname(file) })
        :wait()
      local sha = out.code == 0 and out.stdout:match("^%^?(%x+)")
      if not sha then
        return vim.notify("Blame: " .. vim.trim(out.stderr or ""), vim.log.levels.WARN)
      end
      if sha:match("^0+$") then
        return vim.notify("Blame: line is not committed yet", vim.log.levels.INFO)
      end
      vim.fn.setreg("+", sha)
      vim.fn.setreg('"', sha)
      vim.notify("Yanked " .. sha)
    end, { buffer = args.buf, nowait = true, desc = "Yank commit hash" })
  end,
})
