require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "i" }, "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map({ "n", "i" }, "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
