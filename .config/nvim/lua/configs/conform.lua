local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    json = { "jq" },
    make = { "mbake" },
    cmake = { "cmake_format" },
    sh = { "shuck" },
    bash = { "shuck" },
    zsh = { "shuck" },
    yaml = { "yamlfmt" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  formatters = {
    shuck = {
      command = "shuck",
      args = { "format", "-" },
      stdin = true,
    },

    mbake = {
      command = "mbake",
      args = { "format", "-" },
      stdin = true,
    },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
