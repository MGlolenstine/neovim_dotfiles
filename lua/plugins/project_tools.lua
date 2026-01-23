return {
    -- Project switcher and command picker
    {
        "folke/snacks.nvim", -- Dependency for vim.ui.select
        optional = true,
    },
    {
        name = "project-tools",
        dir = vim.fn.stdpath("config"),
        config = function()
            -- ============================================================
            -- PROJECT SWITCHER
            -- ============================================================

            -- Get project directories from environment variable or use defaults
            -- Set NVIM_PROJECT_DIRS in your shell config (colon-separated):
            -- export NVIM_PROJECT_DIRS="~/cProjects:~/rustProjects:~/tsProjects:~/tmp:~/.config"
            local function get_project_dirs()
                local env_dirs = os.getenv("NVIM_PROJECT_DIRS")
                if env_dirs then
                    local dirs = {}
                    for dir in env_dirs:gmatch("[^:]+") do
                        table.insert(dirs, dir)
                    end
                    return dirs
                end

                -- Default directories if environment variable is not set
                return {
                    "~/cProjects",
                    "~/rustProjects",
                    "~/tsProjects",
                    "~/tmp",
                    "~/.config"
                }
            end

            -- Function to find all projects
            local function find_projects()
                local projects = {}
                local project_dirs = get_project_dirs()

                for _, dir in ipairs(project_dirs) do
                    local expanded = vim.fn.expand(dir)
                    if vim.fn.isdirectory(expanded) == 1 then
                        -- Find all directories that contain a .git folder
                        local handle = io.popen("find " .. expanded .. " -maxdepth 3 -type d -name .git")
                        if handle then
                            for line in handle:lines() do
                                -- Remove the '/.git' part to get the repository root
                                local repo_path = line:gsub("/.git$", "")
                                table.insert(projects, repo_path)
                            end
                            handle:close()
                        end
                    end
                end

                return projects
            end

            -- Function to open project in new Kitty tab
            local function open_project_in_kitty(project_path)
                local cmd = string.format(
                    "kitty @ launch --type=tab --cwd=%s nvim .",
                    vim.fn.shellescape(project_path)
                )
                vim.fn.system(cmd)
            end

            -- Create the project switcher keymap
            vim.keymap.set("n", "<leader>p", function()
                local projects = find_projects()

                vim.ui.select(projects, {
                    prompt = "Select Project:",
                    format_item = function(item)
                        return vim.fn.fnamemodify(item, ":~")
                    end,
                }, function(choice)
                    if choice then
                        open_project_in_kitty(choice)
                    end
                end)
            end, { desc = "Switch to project in new Kitty tab" })

            -- ============================================================
            -- PROJECT COMMAND PICKER
            -- ============================================================

            -- Subdirectories to search for package.json/Makefile
            local SEARCH_SUBDIRS = { ".", "code" }

            -- Try to infer the project root from the current buffer
            local function get_project_root()
                local bufname = vim.api.nvim_buf_get_name(0)
                if bufname ~= "" and vim.fs then
                    local found = vim.fs.find({ ".git", "package.json", "Makefile" }, {
                        upward = true,
                        path = bufname,
                    })
                    if #found > 0 then
                        local dir = vim.fs.dirname(found[1])
                        if dir and dir ~= "" then
                            return dir
                        end
                    end
                end
                return vim.fn.getcwd()
            end

            local function detect_package_manager(root)
                if vim.fn.filereadable(root .. "/pnpm-lock.yaml") == 1 then
                    return "pnpm"
                end
                if vim.fn.filereadable(root .. "/yarn.lock") == 1 then
                    return "yarn"
                end
                if vim.fn.filereadable(root .. "/package-lock.json") == 1 then
                    return "npm"
                end
                return "npm"
            end

            local function build_package_command(pm, script)
                if pm == "yarn" then
                    return string.format("yarn %s", script)
                else
                    return string.format("%s run %s", pm, script)
                end
            end

            local function parse_package_json(root)
                local results = {}
                local path = root .. "/package.json"
                if vim.fn.filereadable(path) ~= 1 then
                    return results
                end

                local ok, content = pcall(vim.fn.readfile, path)
                if not ok or not content or #content == 0 then
                    return results
                end

                local joined = table.concat(content, "\n")
                local ok_json, decoded = pcall(vim.fn.json_decode, joined)
                if not ok_json or type(decoded) ~= "table" or type(decoded.scripts) ~= "table" then
                    return results
                end

                local pm = detect_package_manager(root)
                local display_path = vim.fn.fnamemodify(path, ":~:.")

                for name, _ in pairs(decoded.scripts) do
                    table.insert(results, {
                        name = name,
                        source = string.format("%s (%s)", display_path, pm),
                        cmd = build_package_command(pm, name),
                        cwd = root,
                    })
                end

                table.sort(results, function(a, b)
                    return a.name < b.name
                end)

                return results
            end

            local function parse_makefile(root)
                local results = {}
                local path = root .. "/Makefile"
                if vim.fn.filereadable(path) ~= 1 then
                    return results
                end

                local ok, lines = pcall(vim.fn.readfile, path)
                if not ok or not lines then
                    return results
                end

                local seen = {}
                local display_path = vim.fn.fnamemodify(path, ":~:.")
                for _, line in ipairs(lines) do
                    if not line:match("^%s") and not line:match("^#") then
                        local target = line:match("^([%w%-%._]+)%s*:%s*")
                        if target and not target:match("^%.") and target ~= "PHONY" then
                            if not seen[target] then
                                seen[target] = true
                                table.insert(results, {
                                    name = target,
                                    source = display_path,
                                    cmd = string.format("make %s", target),
                                    cwd = root,
                                })
                            end
                        end
                    end
                end

                table.sort(results, function(a, b)
                    return a.name < b.name
                end)

                return results
            end

            local function open_terminal_in_root(root, cmd)
                local original = vim.fn.getcwd()
                if root ~= "" and root ~= original then
                    vim.cmd("cd " .. vim.fn.fnameescape(root))
                end

                vim.cmd("term " .. cmd)

                if root ~= "" and root ~= original then
                    vim.cmd("cd " .. vim.fn.fnameescape(original))
                end
            end

            local function run_picker()
                local root = get_project_root()
                local items = {}

                -- Collect commands from the project root and subdirectories
                local dirs_to_scan = {}
                for _, sub in ipairs(SEARCH_SUBDIRS) do
                    local dir = root
                    if sub ~= "." and sub ~= "" then
                        dir = root .. "/" .. sub
                    end
                    table.insert(dirs_to_scan, dir)
                end

                for _, dir in ipairs(dirs_to_scan) do
                    for _, item in ipairs(parse_package_json(dir)) do
                        table.insert(items, item)
                    end
                    for _, item in ipairs(parse_makefile(dir)) do
                        table.insert(items, item)
                    end
                end

                if #items == 0 then
                    vim.notify("No package.json scripts or Makefile targets found in project root", vim.log.levels.INFO)
                    return
                end

                vim.ui.select(items, {
                    prompt = string.format("Project commands (%s)", root),
                    format_item = function(item)
                        return string.format("%s \t[%s]", item.name, item.source)
                    end,
                }, function(choice)
                    if not choice then
                        return
                    end
                    open_terminal_in_root(choice.cwd or root, choice.cmd)
                end)
            end

            -- Create the command picker keymap
            vim.keymap.set("n", "<leader>x", run_picker, { desc = "Run project command" })
        end,
    },
}
