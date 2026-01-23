-- LSP commands
vim.keymap.set("n", "<leader>f", function()
    local ft = vim.bo.filetype
    local js_ts_filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

    if vim.tbl_contains(js_ts_filetypes, ft) then
        -- Use ESLint's fix-all for JS/TS files
        vim.cmd("EslintFixAll")
    else
        -- Default LSP formatter for other languages
        vim.lsp.buf.format({ async = true })
    end
end, { desc = "Format buffer" })
vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action)
vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename)

-- Copy utils
vim.keymap.set('v', '<leader>y', '"+y', { desc = "Copy to system clipboard" })

-- File Management
vim.keymap.set('n', '<leader>-', ':Oil<CR>', { desc = "Open file browser in current directory" })
vim.keymap.set('n', '<leader>_', function()
    require("oil").open(vim.fn.systemlist("git rev-parse --show-toplevel")[1])
end, { desc = "Open file browser in current directory" })

-- NeoVIM utils
vim.keymap.set('n', '<leader><leader>', ':so<CR>', { desc = "Source the file" })

-- UndoTree
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)

-- Jump to last change
vim.keymap.set('n', 'g.', 'g;', { desc = 'Jump to last change' })

-- Keybinds
vim.keymap.set("n", "<leader>w", "<cmd>wincmd w<cr>")
vim.keymap.set("v", "ms", "S", { remap = true, desc = "Surround selection" })

-- AugmentCode
vim.keymap.set({"v", "n"}, "<leader>Ac", ":Augment chat<CR>")
vim.keymap.set("n", "<leader>An", ":Augment chat-new<CR>")
vim.keymap.set("n", "<leader>At", ":Augment chat-toggle<CR>")


