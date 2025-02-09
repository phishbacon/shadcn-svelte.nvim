local M = {}

--- Only allow these package_managers
---@alias shadcn.SupportedPackageManagers "pnpm" | "bun" | "yarn" | "npm"

---@class shadcn.PackageManager
---@field component_command_prefix string: The command prefix for adding shadcn-svelte components with the package manager
---@field package_command_prefix string: The command prefix for installing packages with the package manager

---@alias shadcn.PackageManagerInfo table <shadcn.SupportedPackageManagers, shadcn.PackageManager>

---@type shadcn.PackageManagerInfo: Table containing info for supported package managers
local package_managers = {
  ["pnpm"] = { component_command_prefix = "pnpm dlx shadcn-svelte@next add", package_command_prefix = "pnpm i" },
  ["bun"] = { component_command_prefix = "bun x shadcn-svelte@next add", package_command_prefix = "bun install" },
  ["yarn"] = { component_command_prefix = "npx shadcn-svelte@next add", package_command_prefix = "yarn install" },
  ["npm"] = { component_command_prefix = "npx shadcn-svelte@next add", package_command_prefix = "npm i" },
}

--- Only allow these dependency types
---@alias shadcn.DependencyType "component" | "package"

---@class shadcn.Dependency
---@field type shadcn.DependencyType: The type of dependency

---@alias shadcn.Dependencies table<string, shadcn.Dependency>

---@class shadcn.Component
---@field text string
---@field dependencies? shadcn.Dependencies

---@alias shadcn.Components table<string, shadcn.Component>

---@type shadcn.Components
local components = {
  ["accordian"] = {
    text = "accordian",
  },
  ["alert"] = {
    text = "alert"
  },
  ["alert-dialog"] = {
    text = "alert-dialog"
  },
  ["aspect-ratio"] = {
    text = "aspect-ratio"
  },
  ["avatar"] = {
    text = "avatar"
  },
  ["badge"] = {
    text = "badge"
  },
  ["breadcrumb"] = {
    text = "breadcrumb"
  },
  ["button"] = {
    text = "button"
  },
  ["calendar"] = {
    text = "calendar"
  },
  ["card"] = {
    text = "card"
  },
  ["carousel"] = {
    text = "carousel"
  },
  ["checkbox"] = {
    text = "checkbox"
  },
  ["collapsible"] = {
    text = "collapsible"
  },
  ["command"] = {
    text = "command"
  },
  ["context-menu"] = {
    text = "context-menu"
  },
  ["data-table"] = {
    text = "data-table",
    dependencies = {
      ["table"] = {
        type = "component",
      },
      ["@tanstack/table-core"] = {
        type = "package",
      }
    }
  },
  ["dialog"] = {
    text = "dialog"
  },
  ["drawer"] = {
    text = "drawer"
  },
  ["dropdown-menu"] = {
    text = "dropdown-menu"
  },
  ["form"] = {
    text = "form"
  },
  ["hover-card"] = {
    text = "hover-card"
  },
  ["input"] = {
    text = "input"
  },
  ["input-otp"] = {
    text = "input-otp"
  },
  ["label"] = {
    text = "label"
  },
  ["menubar"] = {
    text = "menubar"
  },
  ["pagination"] = {
    text = "pagination"
  },
  ["popover"] = {
    text = "popover"
  },
  ["progress"] = {
    text = "progress"
  },
  ["radio-group"] = {
    text = "radio-group"
  },
  ["range-calendar"] = {
    text = "range-calendar"
  },
  ["resizable"] = {
    text = "resizable"
  },
  ["scroll-area"] = {
    text = "scroll-area"
  },
  ["select"] = {
    text = "select"
  },
  ["separator"] = {
    text = "separator"
  },
  ["sheet"] = {
    text = "sheet"
  },
  ["sidebar"] = {
    text = "sidebar"
  },
  ["skeleton"] = {
    text = "skeleton"
  },
  ["slider"] = {
    text = "slider"
  },
  ["sonner"] = {
    text = "sonner"
  },
  ["switch"] = {
    text = "switch"
  },
  ["table"] = {
    text = "table"
  },
  ["tabs"] = {
    text = "tabs"
  },
  ["textarea"] = {
    text = "textarea"
  },
  ["toggle"] = {
    text = "toggle"
  },
  ["toggle-group"] = {
    text = "toggle-group"
  },
  ["tooltip"] = {
    text = "tooltip"
  },
}

---@class shadcn.WindowSize
---@field width number: The width of the window
---@field height number: The height of the window

---@class shadcn.Keymap
---@field close_window string: The keymap to close the floating window
---
---@class shadcn.Options
---@field package_manager shadcn.SupportedPackageManagers: The package manager to use when installing components and dependencies
---@field window_size shadcn.WindowSize: The size of the floating terminal window
---@field keymap shadcn.Keymap: The keypmaps


--- Default to pnpm and 60 percent window size
---@type shadcn.Options
local options = {
  package_manager = "pnpm",
  window_size = {
    width = math.floor(vim.o.columns * 0.6),
    height = math.floor(vim.o.lines * 0.3),
  },
  keymap = {
    close_window = "<Esc>",
  }
}

---@param component shadcn.Component
---@param opts shadcn.Options
local function create_shadcn_command(component, opts)
  local package_manager_info = package_managers[opts.package_manager]
  local command = ""
  --- We have a component with no dependencies
  if component.dependencies == nil then
    command = package_manager_info.component_command_prefix .. " " .. component.text
    --- We have a component with dependencies
  else
    ---@diagnostic disable-next-line: param-type-mismatch
    for key, value in pairs(component) do
      if value.type == "component" then
        if command == "" then
          command = package_manager_info.component_command_prefix .. " " .. key .. " " .. component.text
        else
          command = command ..
              " && " .. package_manager_info.component_command_prefix .. " " .. key .. " " .. component.text
        end
      elseif value.type == "package" then
        if command == "" then
          command = package_manager_info.package_command_prefix .. " " .. key
        else
          command = command .. " && " .. package_manager_info.package_command_prefix .. " " .. key
        end
      end
    end
  end
  return command
end

---@param command_string string
---@param opts shadcn.Options
local function create_terminal_window(command_string, opts)
  local row = math.floor((vim.o.lines - opts.window_size.height) / 2)
  local col = math.floor((vim.o.columns - opts.window_size.width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = options.window_size.width,
    height = options.window_size.height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_buf_set_keymap(buf, "t", options.keymap.close_window, [[<C-\><C-n>:bwipeout<CR>]],
    { noremap = true, silent = true })
  vim.cmd("term " .. command_string)
  vim.cmd("startinsert")
end

function M.install_component(component_string)
  local component = components[component_string]
  if component ~= nil then
    local command = create_shadcn_command(component, options)
    create_terminal_window(command, options)
  else
    print("Invalid component entered")
  end
end

--- Setup
---@param opts shadcn.Options
M.setup = function(opts)
  options = vim.tbl_deep_extend("force", options, opts or {})
end

return M
