-- Reload buffers that changed on disk (e.g. an AI agent editing many files at
-- once) and make the LSP re-diagnose everything afterwards.
--
-- Two gotchas this works around:
--   1. A bare `:checktime` only checks buffers shown in a window; hidden
--      buffers are skipped. Only `:checktime {bufnr}` checks a hidden one, so
--      we loop over every loaded buffer.
--   2. Pull diagnostics (Roslyn) are only re-requested for a buffer when that
--      buffer itself changes. If B gains a function that A calls, A keeps the
--      stale "undefined" error until A is touched. So after any reload we
--      re-pull diagnostics for every LSP-attached buffer.
local M = {}

local reloaded = false

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = vim.api.nvim_create_augroup("reload_changed_buffers", { clear = true }),
  callback = function(args)
    reloaded = true
    vim.notify("Reloaded " .. vim.fn.fnamemodify(args.file, ":~:."), vim.log.levels.INFO)
  end,
})

local function refresh_diagnostics()
  for _, client in ipairs(vim.lsp.get_clients({ method = "textDocument/diagnostic" })) do
    for bufnr in pairs(client.attached_buffers) do
      -- Private API, but it's exactly what Neovim calls on didChange.
      pcall(vim.lsp.diagnostic._refresh, bufnr, client.id)
    end
  end
end

function M.reload()
  if vim.fn.mode() == "c" then
    return
  end
  reloaded = false
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "" and vim.api.nvim_buf_get_name(bufnr) ~= "" then
      vim.cmd("checktime " .. bufnr)
    end
  end
  if reloaded then
    refresh_diagnostics()
  end
end

return M
