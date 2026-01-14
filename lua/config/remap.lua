-- Telescope
vim.keymap.set('n', '<leader>n', ':Telescope find_files<CR>', { desc = 'Fuzzy find files' })
vim.keymap.set('n', '<leader>b', ':Telescope buffers<CR>', { desc = 'Search through buffers' })
vim.keymap.set('n', '<leader>h', ':Telescope help_tags<CR>', { desc = 'Search through help' })
vim.keymap.set('n', '<leader>l', ':Telescope live_grep<CR>', { desc = 'Live grep search' })
vim.keymap.set('n', '<leader>ss', ':Telescope lsp_document_symbols<CR>', { desc = 'Search through document symbols' })
vim.keymap.set('n', '<leader>sS', ':Telescope lsp_workspace_symbols<CR>', { desc = 'Search through workspace symbols' })
vim.keymap.set('v', '<leader>l', function()
    local builtin = require('telescope.builtin')
    builtin.grep_string()
end, { desc = 'Search selection' })

-- LSP commands
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format buffer' })

-- Copy utils
vim.keymap.set('v', '<leader>y', '"+y', { desc = "Copy to system clipboard" })

-- File Management
vim.keymap.set('n', '<leader>-', ':Oil<CR>', { desc = "Open file browser in current directory" })
vim.keymap.set('n', '<leader>_', function()
    require("oil").open(vim.fn.systemlist("git rev-parse --show-toplevel")[1])
end, { desc = "Open file browser in current directory" })

-- NeoVIM utils
vim.keymap.set('n', '<leader><leader>', ':so<CR>', { desc = "Source the file" })


