return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Default config works great
      -- Use 'ys' for surround, 'ds' for delete, 'cs' for change
    })
  end,
}
