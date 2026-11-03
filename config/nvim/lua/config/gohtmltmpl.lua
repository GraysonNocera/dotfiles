-- Hugo layouts are Go templates that happen to be named `.html`. Neovim 0.12
-- ships no gotmpl filetype, syntax or ftplugin, so they land on the plain
-- `html` parser, which chokes on `{{ ... }}` -- whole regions collapse into
-- ERROR nodes -- and leaves every template action unhighlighted.
--
-- Fix: give those files their own filetype backed by the `gotmpl` parser, with
-- `html` injected back into gotmpl's literal text. That is the same shape the
-- upstream `helm` parser uses to inject yaml, and gotmpl's highlight queries
-- are already written for it (they set `priority 110` so template highlights
-- win over the surrounding host language).
--
-- The parser is registered under its own language name instead of aliasing
-- `gohtmltmpl` -> `gotmpl`, because query files are resolved per *language*:
-- extending `queries/gotmpl/injections.scm` also reaches the `helm` parser,
-- whose queries declare `; inherits: gotmpl`, and would inject html into Helm
-- charts on top of their yaml.

local LANG = "gohtmltmpl"

vim.filetype.add({
  pattern = {
    [".*/layouts/.*%.html"] = LANG,
  },
})

local parser = vim.api.nvim_get_runtime_file("parser/gotmpl.so", false)[1]
if parser then
  pcall(vim.treesitter.language.add, LANG, { path = parser, symbol_name = "gotmpl" })
end

-- LazyVim only starts treesitter for languages nvim-treesitter reports as
-- installed, and it has never heard of `gohtmltmpl`, so drive it from here.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("gohtmltmpl", { clear = true }),
  pattern = LANG,
  callback = function(ev)
    -- No ftplugin ships for this filetype, so `gc` would have nothing to use.
    vim.bo[ev.buf].commentstring = "{{/* %s */}}"

    if not pcall(vim.treesitter.start, ev.buf, LANG) then
      return
    end
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})
