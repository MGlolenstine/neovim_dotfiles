local border = "rounded"  -- or "single", "double", "solid", "shadow"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  { border = border }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  { border = border }
)

-- Also set border for diagnostic floating windows
vim.diagnostic.config({
  float = { border = border }
})
