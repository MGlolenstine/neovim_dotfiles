-- Fix for Neovim 0.11.5 built-in treesitter query error with Python
-- The built-in highlighter queries have a syntax error with "except*" node type
-- 
-- Primary fix: Custom query file at ~/.config/nvim/queries/python/highlights.scm
-- This file overrides the buggy built-in query.
--
-- Fallback: Catch and suppress the error if the custom query doesn't work

-- Override vim.treesitter.start to catch the query error for Python files
-- This is a fallback in case the custom query file doesn't work
local original_treesitter_start = vim.treesitter.start
vim.treesitter.start = function(bufnr, lang, opts)
    -- Only intercept for Python language
    if lang == "python" then
        local ok, result = pcall(original_treesitter_start, bufnr, lang, opts)
        if not ok then
            local error_msg = tostring(result)
            -- Suppress the "except*" query error - custom query file should handle it
            if error_msg:match("except%*") or error_msg:match("Invalid node type") or error_msg:match("Query error") then
                -- Silently fail - nvim-treesitter will handle highlighting
                return false
            end
            -- Re-throw other errors
            error(result)
        end
        return result
    end
    -- For other languages, use the original function
    return original_treesitter_start(bufnr, lang, opts)
end
