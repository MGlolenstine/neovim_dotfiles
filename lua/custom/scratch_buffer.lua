local M = {}

-- Keep track of the buffer ID globally within this module's lifecycle
M.scratch_buf = M.scratch_buf or nil

function M.toggle_scratchpad()
  -- 1. Create the buffer if it doesn't exist yet
  if not M.scratch_buf or not vim.api.nvim_buf_is_valid(M.scratch_buf) then
    M.scratch_buf = vim.api.nvim_create_buf(false, true) -- (listed=false, scratchpad/nofile=true)
    vim.api.nvim_buf_set_name(M.scratch_buf, "*Scratchpad*")

    -- Optional: Set filetype to markdown so you get syntax highlighting in your scratchpad
    vim.api.nvim_set_option_value('filetype', 'markdown', { buf = M.scratch_buf })
  end

  -- 2. If the window is already open somewhere, find it and close it (Toggle off)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == M.scratch_buf then
      vim.api.nvim_win_close(win, true)
      return
    end
  end

  -- 3. Calculate dynamic dimensions for a clean, centered floating window
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- 4. Window configuration options
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Scratchpad (Persistent) ",
    title_pos = "center",
  }

  -- 5. Open the window and map 'q' or 'Esc' to close it easily
  local win = vim.api.nvim_open_win(M.scratch_buf, true, win_opts)
  -- Local keymaps for the scratchpad buffer to tuck it away quickly
  vim.keymap.set('n', 'q', ':close<CR>', { buffer = M.scratch_buf, silent = true })
  vim.keymap.set('n', '<Esc>', ':close<CR>', { buffer = M.scratch_buf, silent = true })
end

-- Keymap to toggle it globally
vim.keymap.set('n', '<leader>bs', M.toggle_scratchpad, { desc = '[B]uffer: Toggle [S]cratchpad' })

return M
