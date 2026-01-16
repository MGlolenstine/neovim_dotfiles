return {
    -- Mason MUST be first
    {
        "williamboman/mason.nvim",
        lazy = false,    -- Load immediately
        priority = 1000, -- Load before everything
        config = function()
            require("mason").setup()
        end,
    },

    -- Then mason-lspconfig
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local border = "rounded"

            -- Set border for lspconfig UI windows
            require('lspconfig.ui.windows').default_options.border = border

            -- Override the default hover handler to force borders
            local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
            function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
                opts = opts or {}
                opts.border = opts.border or border
                return orig_util_open_floating_preview(contents, syntax, opts, ...)
            end

            -- Default capabilities from nvim-cmp (with fallback)
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
            if has_cmp then
                capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
            end

            -- Now setup mason-lspconfig with handlers
            local lspconfig = require("lspconfig")

            require("mason-lspconfig").setup({
                automatic_installation = true,
                ensure_installed = {
                    -- Lua
                    "lua_ls",
                    -- Rust
                    "rust_analyzer",
                    -- TypeScript/JavaScript
                    "ts_ls",
                    "eslint",
                    "denols",
                },
                handlers = {
                    -- Default handler for all servers
                    function(server_name)
                        lspconfig[server_name].setup({
                            capabilities = capabilities,
                        })
                    end,

                    -- Custom handler for lua_ls
                    ["lua_ls"] = function()
                        lspconfig.lua_ls.setup({
                            capabilities = capabilities,
                            settings = {
                                Lua = {
                                    diagnostics = {
                                        globals = { "vim" },
                                    },
                                    workspace = {
                                        library = vim.api.nvim_get_runtime_file("", true),
                                        checkThirdParty = false,
                                    },
                                    telemetry = {
                                        enable = false,
                                    },
                                    hint = {
                                        enable = true,
                                        semicolon = "Disable",
                                    },
                                    codeLens = {
                                        enable = true,
                                    },
                                },
                            },
                        })
                    end,

                    -- Custom handler for rust_analyzer
                    ["rust_analyzer"] = function()
                        lspconfig.rust_analyzer.setup({
                            capabilities = capabilities,
                            settings = {
                                ["rust-analyzer"] = {
                                    lens = {
                                        enable = true,
                                        debug = { enable = true },
                                        implementations = { enable = true },
                                        run = { enable = true },
                                        references = {
                                            adt = { enable = true },
                                            enumVariant = { enable = true },
                                            method = { enable = true },
                                            trait = { enable = true },
                                        },
                                    },
                                },
                            },
                        })
                    end,

                    -- Custom handler for TypeScript/JavaScript
                    ["ts_ls"] = function()
                        lspconfig.ts_ls.setup({
                            capabilities = capabilities,
                            on_attach = function(client, bufnr)
                                client.server_capabilities.documentFormattingProvider = false
                                client.server_capabilities.documentRangeFormattingProvider = false
                            end,
                        })
                    end,

                    -- Custom handler for ESLint
                    ["eslint"] = function()
                        lspconfig.eslint.setup({
                            capabilities = capabilities,
                        })
                    end,

                    -- Custom handler for Deno
                    ["denols"] = function()
                        lspconfig.denols.setup({
                            capabilities = capabilities,
                            settings = {
                                deno = {
                                    enable = true,
                                    suggest = {
                                        imports = {
                                            hosts = {
                                                ["https://deno.land"] = true,
                                            },
                                        },
                                    },
                                },
                            },
                        })
                    end,
                },
            })
        end,
    },

    -- Finally lspconfig (loaded as dependency, no config needed here)
    {
        "neovim/nvim-lspconfig",
        lazy = false,
    },
}
