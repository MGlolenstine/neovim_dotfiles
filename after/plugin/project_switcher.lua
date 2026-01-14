-- Define your project directories
local project_dirs = {
  "~/cProjects",
  "~/rustProjects",
  "~/tsProjects",
  "~/tmp"
}

-- Function to find all projects
local function find_projects()
  local projects = {}
  
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

-- Create the picker using vim.ui.select (works with Snacks)
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
