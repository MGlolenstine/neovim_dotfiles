local M = {}

local state = {
  buf = nil,
  win = nil,
  chapter = 1,
}

local chapters = {
  {
    title = 'Start Here',
    lines = {
      'This tutorial teaches the custom parts of your Neovim setup.',
      '',
      'Use these keys inside the tutorial:',
      '  n  next chapter',
      '  p  previous chapter',
      '  q  quit',
      '',
      'You can also open a specific chapter with `:NvimTutor 3`.',
      '',
      'When you forget a builtin feature, try `:help` or `<leader>sh`.',
    },
  },
  {
    title = 'Movement and Windows',
    lines = {
      'Your config keeps the classic hjkl movement and adds easier window switching.',
      '',
      'Try these mappings:',
      '  <C-h>  move to left window',
      '  <C-j>  move to lower window',
      '  <C-k>  move to upper window',
      '  <C-l>  move to right window',
      '',
      'You can also move the current window itself:',
      '  <C-S-h/j/k/l>  send the window to another side',
      '',
      'Tip: `:help wincmd` explains the built-in window commands.',
    },
  },
  {
    title = 'Search Like a Pro',
    lines = {
      'Telescope is the center of your search workflow.',
      '',
      'Useful mappings:',
      '  <leader>sf  find files',
      '  <leader>sg  live grep across the project',
      '  <leader>sh  search help tags',
      '  <leader>sk  search keymaps',
      '  <leader>sc  search commands',
      '  <leader><leader>  list open buffers',
      '  <leader>/   fuzzy search inside the current buffer',
      '',
      'For your notes:',
      '  <leader>nt  open today\'s journal note',
      '  <leader>nf  find note files',
      '  <leader>ns  search note text',
      '  <leader>ng  search note tags',
    },
  },
  {
    title = 'LSP Workflow',
    lines = {
      'When a language server attaches, your buffer gets several powerful actions.',
      '',
      'Navigation:',
      '  gd   go to definition',
      '  gr   find references',
      '  gi   go to implementation',
      '  gt   go to type definition',
      '  gO   document symbols',
      '  gW   workspace symbols',
      '',
      'Editing:',
      '  grn  rename symbol',
      '  gra  code action',
      '  grD  go to declaration',
      '  <leader>th  toggle inlay hints',
      '',
      'Diagnostics open automatically when you jump to them.',
      'Use `<leader>e` to send diagnostics to the quickfix list.',
    },
  },
  {
    title = 'Editing Power',
    lines = {
      'This setup gives you a few strong editing helpers.',
      '',
      'Formatting:',
      '  <leader>f  format the current buffer',
      '',
      'Surround and textobjects from mini.nvim:',
      '  saiw)  add surrounding parens around a word',
      '  sd"    delete a surrounding quote',
      '  sr)"   replace a surrounding',
      '  aa / ii  around-inside textobjects',
      '',
      'Completion and snippets:',
      '  <c-space>  completion docs or menu',
      '  <c-n>/<c-p>  next/previous completion item',
      '  <tab>      move through snippets',
    },
  },
  {
    title = 'Custom Extras',
    lines = {
      'A few custom helpers round out the config.',
      '',
      '  <leader>bs  toggle the persistent scratchpad',
      '  <C-f>       open the tmux session switcher popup',
      '',
      'The scratchpad is a markdown buffer you can leave open for quick notes.',
      'The tmux launcher is meant for fast project switching.',
      '',
      'Practice idea:',
      '  open a file, jump to a definition, rename a symbol, format it, and grep for a term.',
    },
  },
}

local function clamp_chapter(n)
  n = tonumber(n) or 1
  if n < 1 then return 1 end
  if n > #chapters then return #chapters end
  return n
end

local function ensure_buffer()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    return state.buf
  end

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].buftype = 'nofile'
  vim.bo[state.buf].bufhidden = 'wipe'
  vim.bo[state.buf].swapfile = false
  vim.bo[state.buf].modifiable = false
  vim.bo[state.buf].filetype = 'markdown'
  return state.buf
end

local function render()
  local buf = ensure_buffer()
  local chapter = chapters[state.chapter]
  local lines = {
    '# Nvim Tutor',
    '',
    ('## Chapter %d of %d: %s'):format(state.chapter, #chapters, chapter.title),
    '',
  }

  for _, line in ipairs(chapter.lines) do
    lines[#lines + 1] = line
  end

  lines[#lines + 1] = ''
  lines[#lines + 1] = 'Use `n` and `p` to move between chapters. Press `q` to close.'

  vim.bo[buf].readonly = false
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true

  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    vim.api.nvim_win_set_buf(state.win, buf)
  end
end

local function open_window(buf)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - width) / 2)

  state.win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
  })

  vim.wo[state.win].wrap = true
  vim.wo[state.win].linebreak = true
  vim.wo[state.win].number = false
  vim.wo[state.win].relativenumber = false
  vim.wo[state.win].signcolumn = 'no'
  vim.wo[state.win].cursorline = false
end

local function close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
end

local function next_chapter()
  if state.chapter < #chapters then
    state.chapter = state.chapter + 1
    render()
  end
end

local function prev_chapter()
  if state.chapter > 1 then
    state.chapter = state.chapter - 1
    render()
  end
end

function M.open(opts)
  state.chapter = clamp_chapter(opts and opts.chapter or 1)
  local buf = ensure_buffer()

  if not (state.win and vim.api.nvim_win_is_valid(state.win)) then
    open_window(buf)
  else
    vim.api.nvim_set_current_win(state.win)
  end

  render()

  vim.keymap.set('n', 'n', next_chapter, { buffer = buf, silent = true, nowait = true, desc = 'Next chapter' })
  vim.keymap.set('n', 'p', prev_chapter, { buffer = buf, silent = true, nowait = true, desc = 'Previous chapter' })
  vim.keymap.set('n', 'q', close, { buffer = buf, silent = true, nowait = true, desc = 'Close tutorial' })
  vim.keymap.set('n', '<Esc>', close, { buffer = buf, silent = true, nowait = true, desc = 'Close tutorial' })
end

vim.api.nvim_create_user_command('NvimTutor', function(opts)
  M.open({ chapter = opts.args })
end, {
  nargs = '?',
  desc = 'Open the custom Neovim tutorial',
  complete = function(ArgLead)
    local items = {}
    for i, chapter in ipairs(chapters) do
      local label = ('%d'):format(i)
      if vim.startswith(label, ArgLead) or vim.startswith(chapter.title:lower(), ArgLead:lower()) then
        items[#items + 1] = label
      end
    end
    return items
  end,
})

return M
