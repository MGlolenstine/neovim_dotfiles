return {
  "mg979/vim-visual-multi",
  branch = "master",
  init = function()
    vim.g.VM_maps = {
      ['Find Under'] = '<C-d>', -- Ctrl-d like VSCode
      ['Visual Regex'] = 's',   -- Helix-style!
    }
  end,
  keys = {
    { 's', mode = 'x', desc = 'Multi-cursor regex search' },
    { '<C-d>', mode = {'n', 'x'}, desc = 'Select next occurrence' },
  },
}

