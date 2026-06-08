local M = {}

---@param args string[]
---@param cwd string
---@return string? stdout
local function git_cmd(args, cwd)
	local result = vim.system(args, { cwd = cwd, text = true }):wait()
	if result.code ~= 0 then
		return nil
	end
	return ((result.stdout or ""):gsub("%s+$", ""))
end

---@param s string
---@return string
local function encode_segment(s)
	return (s:gsub("([^%w%-%.%_%~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

---@param path string
---@return string
local function encode_path(path)
	local parts = vim.split(path, "/", { plain = true })
	for i, part in ipairs(parts) do
		parts[i] = encode_segment(part)
	end
	return table.concat(parts, "/")
end

---@param output string
---@return string?
local function parse_remote_v(output)
	local origin_url = nil
	local fallback_url = nil
	for line in output:gmatch("[^\r\n]+") do
		if line:match("%(fetch%)") then
			local name, url = line:match("^(%S+)%s+(%S+)")
			if name and url then
				if name == "origin" then
					origin_url = url
				elseif not fallback_url then
					fallback_url = url
				end
			end
		end
	end
	return origin_url or fallback_url
end

---@param url string
---@return string?
local function normalize_remote_url(url)
	local host, path = url:match("^git@([^:]+):(.+)$")
	if host and path then
		path = path:gsub("%.git$", "")
		return "https://" .. host .. "/" .. path
	end

	host, path = url:match("^ssh://git@([^/]+)/(.+)$")
	if host and path then
		path = path:gsub("%.git$", "")
		return "https://" .. host .. "/" .. path
	end

	if url:match("^https?://") then
		return (url:gsub("%.git$", ""))
	end

	return nil
end

---@param root string
---@param path string
---@return string?
local function relpath_from_root(root, path)
	root = vim.fn.resolve(root)
	path = vim.fn.resolve(path)
	if path == root then
		return ""
	end
	if path:sub(1, #root) ~= root or path:sub(#root + 1, #root + 1) ~= "/" then
		return nil
	end
	return path:sub(#root + 2)
end

---@param base string
---@param branch string
---@param rel_path string
---@return string
local function build_github_tree_url(base, branch, rel_path)
	if rel_path == "" then
		return ("%s/tree/%s"):format(base, encode_path(branch))
	end
	return ("%s/tree/%s/%s"):format(base, encode_path(branch), encode_path(rel_path))
end

---@param base string
---@param branch string
---@param rel_path string
---@param line_start? integer
---@param line_end? integer
---@return string
local function build_github_blob_url(base, branch, rel_path, line_start, line_end)
	local url = ("%s/blob/%s/%s"):format(base, encode_path(branch), encode_path(rel_path))
	if line_start and line_end then
		if line_start == line_end then
			url = url .. ("#L%d"):format(line_start)
		else
			url = url .. ("#L%d-L%d"):format(line_start, line_end)
		end
	end
	return url
end

---@class GitRepoContext
---@field git_root string
---@field branch string
---@field base string

---@param start_dir string
---@return GitRepoContext?
local function get_git_repo_context(start_dir)
	local git_root = git_cmd({ 'git', 'rev-parse', '--show-toplevel' }, start_dir)
	if not git_root then
		vim.notify('Not in a git repository', vim.log.levels.WARN)
		return nil
	end

	local branch = git_cmd({ 'git', 'rev-parse', '--abbrev-ref', 'HEAD' }, git_root)
	if not branch then
		vim.notify('Could not determine current branch', vim.log.levels.WARN)
		return nil
	end

	local remote_output = git_cmd({ 'git', 'remote', '-v' }, git_root)
	if not remote_output then
		vim.notify('Could not read git remotes', vim.log.levels.WARN)
		return nil
	end

	local remote_url = parse_remote_v(remote_output)
	if not remote_url then
		vim.notify('No git remote found', vim.log.levels.WARN)
		return nil
	end

	local base = normalize_remote_url(remote_url)
	if not base then
		vim.notify('Unsupported remote URL: ' .. remote_url, vim.log.levels.WARN)
		return nil
	end

	return { git_root = git_root, branch = branch, base = base }
end

---@param line_start? integer
---@param line_end? integer
local function open_git_in_browser(line_start, line_end)
	local oil_dir = require('oil').get_current_dir()
	if oil_dir then
		local ctx = get_git_repo_context(oil_dir)
		if not ctx then
			return
		end

		local rel_path = relpath_from_root(ctx.git_root, oil_dir)
		if rel_path == nil then
			vim.notify('Could not determine directory path relative to repository', vim.log.levels.WARN)
			return
		end

		vim.ui.open(build_github_tree_url(ctx.base, ctx.branch, rel_path))
		return
	end

	local filepath = vim.api.nvim_buf_get_name(0)
	if filepath == '' then
		vim.notify('No file path for current buffer', vim.log.levels.WARN)
		return
	end

	local ctx = get_git_repo_context(vim.fn.fnamemodify(filepath, ':h'))
	if not ctx then
		return
	end

	local rel_path = relpath_from_root(ctx.git_root, filepath)
	if not rel_path then
		vim.notify('Could not determine file path relative to repository', vim.log.levels.WARN)
		return
	end

	vim.ui.open(build_github_blob_url(ctx.base, ctx.branch, rel_path, line_start, line_end))
end

vim.keymap.set('n', '<leader>goo', function()
	open_git_in_browser()
end, { desc = '[G]it [O]pen in browser (file or oil dir)' })

vim.keymap.set('v', '<leader>goo', function()
	local start = vim.fn.line('v')
	local finish = vim.fn.line('.')
	if start > finish then
		start, finish = finish, start
	end
	open_git_in_browser(start, finish)
end, { desc = '[G]it [O]pen selection in browser' })

vim.pack.add({
	{ src = 'https://github.com/NeogitOrg/neogit' },
	{ src = 'https://github.com/nvim-lua/plenary.nvim' },
	{ src = 'https://github.com/sindrets/diffview.nvim' },
})

require('neogit').setup({})
vim.keymap.set('n', '<leader>gg', require('neogit').open, { desc = 'Open Neogit UI' })

return M
