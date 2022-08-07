-- ┌                                                          ┐
-- │  Copyright (c) 2022 NTBBloodbath. All rights reserved.   │
-- │  Use of this source code is governed by a GPL3 license   │
-- │          that can be found in the LICENSE file.          │
-- └                                                          ┘
local config = {}

--- zig-tools.nvim configuration
local defaults = {
  --- Commands to interact with your project compilation
  expose_commands = true,
  --- Format source code
  formatter = {
    --- Enable formatting, create commands
    enable = true,
    --- Events to run formatter, empty to disable
    events = {},
  },
  --- Check for compilation-time errors
  checker = {
    --- Enable checker, create commands
    enable = true,
    --- Run before trying to compile?
    before_compilation = true,
    --- Events to run checker
    events = {},
  },
  --- Project compilation helpers
  project = {
    --- Extract all build tasks from `build.zig` and expose them
    build_tasks = true,
    --- Enable rebuild project on save? (`:ZigLive` command)
    live_reload = true,
    --- Extra flags to be passed to compiler
    flags = {
      --- `zig build` flags
      build = {"--prominent-compile-errors"},
      --- `zig run` flags
      run = {},
    },
    --- Automatically compile your project from within Neovim
    auto_compile = {
      --- Enable automatic compilation
      enable = false,
      --- Automatically run project after compiling it
      run = true,
    },
  },
  --- zig-tools.nvim integrations
  integrations = {
    --- Third-party Zig packages manager integration
    package_managers = {"zigmod", "gyro"},
    --- Zig Language Server
    zls = {
      --- Enable inlay hints
      hints = true,
      --- Manage installation
      management = {
        --- Enable ZLS management
        enable = false,
        --- Installation path
        install_path = os.getenv("HOME") .. "/.local/bin",
        --- Source path (where to clone repository when building from source)
        source_path = os.getenv("HOME") .. "/.local/zig/zls",
      },
    },
  }
}

--- Get a configuration option or all configurations
---@param opt string|nil Configuration option
---@return any
config.get = function(opt)
  return opt ~= nil and defaults[opt] or defaults
end

--- Set configuration options
---@param opts table Configuration options
---@return table|nil
config.set = function(opts)
  vim.validate({
    opts = {opts, "table"}
  })
  return vim.tbl_deep_extend("force", defaults, opts)
end

return config
