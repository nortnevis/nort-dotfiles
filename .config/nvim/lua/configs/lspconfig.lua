require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("opencl_ls", {
  filetypes = { "cl", "lisp" }, -- lisp, because nvim-lspconfig treats .cl files as a lisp
})

vim.lsp.config("clangd", {
  cmd = { "clangd", "--header-insertion=never" },
})

local servers = { "html", "cssls", "clangd", "opencl_ls", "stylua" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
