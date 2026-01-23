-- Bootstrap and load plugin manager
require("config.lazy")

-- Load Neovim configuration
require("config.options")
require("config.keymaps")

-- Treesitter fix for Neovim 0.11.5 Python query error
-- This can be removed when upgrading to a newer Neovim version
require("config.treesitter_fix")

-- Setup oil.nvim file explorer
require("oil").setup()
