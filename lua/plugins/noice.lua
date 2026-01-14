-- return {
--   "folke/noice.nvim",
--   opts = {
--     presets = {
--       lsp_doc_border = true,
--     },
--   },
-- }
--
return {
  "folke/noice.nvim",
  opts = {
    lsp = {
      -- Only enable hover
      hover = {
        enabled = true,
      },
      signature = {
        enabled = false,
      },
      progress = {
        enabled = false,
      },
      message = {
        enabled = false,
      },
    },
    presets = {
      lsp_doc_border = true,
    },
    -- Disable everything else
    cmdline = {
      enabled = false,
    },
    messages = {
      enabled = false,
    },
    popupmenu = {
      enabled = false,
    },
    notify = {
      enabled = false,
    },
    -- Route all messages away
    routes = {
      {
        filter = {
          event = "msg_show",
        },
        opts = { skip = true },
      },
    },
  },
}
