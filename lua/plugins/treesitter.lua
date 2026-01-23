local M = {
  "nvim-treesitter/nvim-treesitter",
  tag = "v0.10.0",
  lazy = false,
}

function M.init() vim.opt.foldlevelstart = 99 end

function M.config()
  require "nvim-treesitter.configs".setup {
    auto_install = true,
    sync_install = false,
    ignore_install = {},
    ensure_installed = { "c", "lua", "vim", "vimdoc", "python" },
    modules = {},
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
      disable = function(lang, buf)
        -- Disable for very large files
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
        -- Temporarily disable for Python to avoid "except*" query error in Neovim 0.11.5
        -- This will be re-enabled once the query error is fixed
        if lang == "python" then
          return false -- Keep enabled, but the fix will catch the error
        end
      end,
    },
    indent = {
      enable = false,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>",
        node_incremental = "<CR>",
        node_decremental = "<BS>",
      },
    },
  }
end

--NOTE: install mandatory parsers on build
function M.build()
  local ensure_installed = {
    "c",
    "lua",
    "vim",
    "vimdoc",
    "python",
    "markdown",
    "regex",
    "markdown_inline",
    "bash",
    "gitcommit",
    "git_config",
    "git_rebase",
    "gitattributes",
  }
  vim.cmd("TSUpdateSync " .. table.concat(ensure_installed, " "))
end

return M
