-- LSP commands
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format buffer' })
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

-- Keybinds
vim.keymap.set("n", "<leader>w", "<cmd>wincmd w<cr>")
vim.keymap.set("i", "<cr>", function()
    ---@diagnostic disable-next-line
    local line = vim.fn.getline "."
    local col = vim.fn.col "."
    ---@diagnostic disable-next-line
    local next = line:sub(col, col)
    if vim.tbl_contains({ "}", "]" }, next) then return "<cr><esc>ko" end
    return "<cr>"
end, { expr = true })
vim.keymap.set("v", "ms", "S", { remap = true, desc = "Surround selection" })

-- AugmentCode
vim.keymap.set({"v", "n"}, "<leader>Ac", ":Augment chat<CR>")
vim.keymap.set("n", "<leader>An", ":Augment chat-new<CR>")
vim.keymap.set("n", "<leader>At", ":Augment chat-toggle<CR>")


