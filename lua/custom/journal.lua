local M = {}
-- Change this to your preferred local notes directory
local notes_dir = vim.fn.expand('~/notes/') 

-- Ensure the directory exists
if vim.fn.isdirectory(notes_dir) == 0 then
  vim.fn.mkdir(notes_dir, 'p')
end

-- 1. Open Today's Journal Note
function M.open_todays_note()
  local date = os.date('%Y-%m-%d')
  local filename = notes_dir .. date .. '.md'
  local file_exists = vim.fn.filereadable(filename) == 1

  vim.cmd('edit ' .. filename)

  -- If it's a new file, seed it with Markdown frontmatter
  if not file_exists then
    local lines = {
      "---",
      "title: Journal " .. date,
      "date: " .. date,
      "tags: [ journal ]",
      "---",
      "",
      "# " .. date,
      "",
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.cmd('write')
    -- Position cursor at the end of the file
    vim.cmd('normal! G')
  end
end

-- 2. Search Note Content using Telescope
function M.search_notes()
  require('telescope.builtin').live_grep({
    cwd = notes_dir,
    prompt_title = "Search Note Contents",
  })
end

-- 3. Find Notes by Filename / Title
function M.find_notes()
  require('telescope.builtin').find_files({
    cwd = notes_dir,
    prompt_title = "Find Notes",
  })
end

-- 4. Find Notes by Tag (Grep for frontmatter tags)
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values
local make_entry = require('telescope.make_entry')

function M.find_tags()
  pickers.new({}, {
    prompt_title = "Search Tags (Space Separated)",
    -- Run ripgrep to find all lines starting with 'tags:' in your notes directory
    finder = finders.new_job(
      function(prompt)
        -- We only search for the frontmatter line anchor '^tags:'
        return { "rg", "--vimgrep", "^tags:", notes_dir }
      end,
      -- Use Telescope's default grep entry maker so it knows how to parse 
      -- file paths, line numbers, and column numbers for previewing/opening.
      make_entry.gen_from_vimgrep({})
    ),
    previewer = conf.grep_previewer({}),
    sorter = conf.generic_sorter({}),
  }):find()
end

-- Keymaps
vim.keymap.set('n', '<leader>nt', M.open_todays_note, { desc = '[N]ote: Open [T]oday\'s' })
vim.keymap.set('n', '<leader>nf', M.find_notes, { desc = '[N]ote: [F]ind File' })
vim.keymap.set('n', '<leader>ns', M.search_notes, { desc = '[N]ote: [S]earch Text' })
vim.keymap.set('n', '<leader>ng', M.find_tags, { desc = '[N]ote: Search [G]g/Tags' })

return M
