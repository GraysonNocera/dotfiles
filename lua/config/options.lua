-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
opt.smoothscroll = false
opt.scrolloff = 5
opt.sidescrolloff = 5

-- Enable 24-bit truecolor (needed for correct colors inside tmux).
opt.termguicolors = true
