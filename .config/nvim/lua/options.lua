require "nvchad.options"

-- add yours here!

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.expandtab = false

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = "a"
vim.opt.mousescroll = "ver:1,hor:6"

vim.opt.clipboard = "unnamedplus"

vim.opt.exrc = true -- Enable searching local configs
vim.opt.secure = true -- Enable requests for using local configs

-- usage: create '.nvim.lua' file

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
