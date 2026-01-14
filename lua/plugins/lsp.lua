return {
  -- Mason MUST be first
  {
    "williamboman/mason.nvim",
    lazy = false,  -- Load immediately
    priority = 1000,  -- Load before everything
    config = function()
      require("mason").setup()
    end,
  },
  
  -- Then mason-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        automatic_installation = true,
      })
    end,
  },
  
  -- Finally lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    init = function()
      local border = "rounded"
      
      -- Hover
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover,
        { border = border }
      )
      
      -- Signature help
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help,
        { border = border }
      )
      
      -- Set border for lspconfig windows
      require('lspconfig.ui.windows').default_options.border = border

      print("LSP borders configured!")
    end,
  },
}
