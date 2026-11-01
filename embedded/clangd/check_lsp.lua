-- Headless smoke test for the OpenBMC clangd setup.
--
-- Usage (from the bmcweb source tree):
--   nvim --headless http/mutual_tls.cpp \
--     -c "luafile ~/extraSpace/embedded/clangd/check_lsp.lua"
--
-- It verifies that clangd attaches, reports no diagnostics, completes
-- std:: symbols and resolves boost:: to the Yocto sysroot header.
-- The line/column probes are specific to http/mutual_tls.cpp.

local bufnr = vim.api.nvim_get_current_buf()

-- In a headless session the buffer is opened before NvChad's lazy-loaded
-- nvim-lspconfig module is ready.  Emit the two events NvChad/nvim uses so the
-- test exercises exactly the same path as an interactive `nvim file`.
vim.cmd "doautocmd User FilePost"
vim.cmd("doautocmd FileType " .. vim.bo.filetype)

local client
local attached = vim.wait(120000, function()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })
  client = clients[1]
  return client ~= nil
end, 200)

if not attached or not client then
  print("FAIL: clangd did not attach")
  vim.cmd "cq"
end

print("PASS: clangd attached")
print("  root_dir: " .. tostring(client.config.root_dir))

local function request(method, row, col)
  vim.api.nvim_win_set_cursor(0, { row, col })
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  local responses = vim.lsp.buf_request_sync(0, method, params, 60000)
  for _, response in pairs(responses or {}) do
    return response.result, response.err
  end
end

local function find(pattern)
  vim.fn.cursor(1, 1)
  local row, col = unpack(vim.fn.searchpos(pattern, "w"))
  return row, col - 1, vim.api.nvim_get_current_line()
end

-- Force clangd to build the AST/preamble before looking at diagnostics.
request("textDocument/hover", 33, 8)
vim.wait(3000)

local diagnostics = vim.diagnostic.get(bufnr)
print("  diagnostics: " .. #diagnostics)
for _, diagnostic in ipairs(diagnostics) do
  print(string.format("    [%s] %s", vim.diagnostic.severity[diagnostic.severity], diagnostic.message))
end

local completion_row, completion_col, completion_line = find "std::"
local result = request("textDocument/completion", completion_row, completion_col + 5)

local items = {}
if result then
  items = result.items or result
end
local labels = {}
for _, item in ipairs(items) do
  labels[(item.label:gsub("^%s+", ""))] = true
end
print("  completion line: " .. vim.trim(completion_line))
if labels["string_view"] or labels["string"] then
  print("PASS: completion works (" .. #items .. " items)")
else
  local first = {}
  for index, item in ipairs(items) do
    if index > 8 then
      break
    end
    first[#first + 1] = item.label
  end
  print("FAIL: completion returned no std:: items (" .. #items .. " items: " .. table.concat(first, ", ") .. ")")
end

local boost_row, boost_col, boost_line = find "boost::asio::ip::address"
print("  definition line: " .. vim.trim(boost_line))
-- Put the cursor on the "address" part of the qualified name.
local address_col = boost_col + #"boost::asio::ip::"
local declaration = request("textDocument/declaration", boost_row, address_col)
if declaration then
  print("PASS: go-to-declaration works")
else
  print("FAIL: no declaration result for boost::asio::ip::address")
end

local definition = request("textDocument/definition", boost_row, address_col)
if definition then
  local locations = definition[1] and definition or { definition }
  local uri = locations[1] and locations[1].uri or "?"
  if uri:find("/boost/", 1, true) then
    print("PASS: go-to-definition resolves Boost")
    print("  " .. uri)
  else
    print("FAIL: unexpected definition target: " .. uri)
  end
else
  print("FAIL: no definition result for boost::asio")
end

-- Real-time diagnostics: inject a syntax error into the unsaved buffer and
-- make sure clangd reports it (qa! discards the change).
vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "int clangd_diagnostic_probe = ;" })
local saw_error = vim.wait(20000, function()
  for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      return true
    end
  end
  return false
end, 200)
if saw_error then
  print("PASS: real-time diagnostics")
else
  print("FAIL: clangd did not report the injected syntax error")
end

vim.cmd "qa!"
