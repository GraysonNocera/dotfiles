-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
opt.smoothscroll = false
opt.scrolloff = 5
opt.sidescrolloff = 5

-- Enable 24-bit truecolor (needed for correct colors inside tmux).
opt.termguicolors = true

-- Pin LazyVim's "Root Dir" to the working directory. By default LazyVim
-- re-detects a root per buffer (LSP workspace, then .git / root patterns), so
-- in this multi-root repo (SSHManWeb .sln, .github/workflows, infrastructure/)
-- the scope of <leader>ff / <leader>e keeps snapping to whatever project the
-- current file belongs to. Forcing { "cwd" } keeps those keys anchored at the
-- repo top; use the scoped maps in keymaps.lua to dip into a subtree.
vim.g.root_spec = { "cwd" }

-- Treat Hugo layouts as Go templates rather than plain HTML. Loaded from here
-- because `config.options` runs before any buffer is read, so the filetype
-- pattern and its FileType autocmd are in place for the first file opened.
require("config.gohtmltmpl")
