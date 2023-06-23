# zig-tools.nvim

zig-tools.nvim is a Neovim (>= 0.7.x) plugin that adds some Zig-specific features to Neovim. WIP.

zig-tools.nvim aims to provide Zig integration to your favorite editor, and that integration is a
swiss army knife, all-in-one. That means, zig-tools.nvim will provide an integration with Zig
build system (by using your project `build.zig`), available third-party dependencies managers
(zigmod and gyro) and ZLS (Zig Language Server).

For example, zig-tools.nvim will create commands to run specific `build.zig` tasks, compile
_and run_ your project, live _automatic_ rebuild, add/remove/update dependencies, etc.


## Design mantra

- **Freedom**. You are free to use _and do_ only what you want and only when you want.
  zig-tools.nvim will never force you to use one of its features.
- **Simplicity**. Development tools should be mnemonic, easy to understand _and use_.
- **Your setup, your choices**. Nobody better than you knows what is best for your system and your
  Neovim setup, zig-tools.nvim will take care not to get in your way.


## Features

- Zig build system integration.
    - Compile _and run_ your project.
    - Live rebuild on changes.
    - Run your additional build tasks (e.g. `zig build tests`).
- opt-in Zig third-party dependencies managers integration (add, remove and update your
  zigmod/gyro dependencies on the fly!).
- opt-in LSP integration (with support for inlay hints (maybe? seems to not work with zls yet),
  thanks to rust-tools.nvim author). See [FAQ](#faq) if you have questions about this integration.


## Requirements

### System-wide

- git (optional, required by zls integration)
- curl / wget (optional, required by zls integration)
- Neovim (>= 0.7.x)
- ripgrep (>= 11.0)


### Neovim

- [akinsho/toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)


## Installation

You can use your favorite plugins manager to get zig-tools.nvim, we are going to use packer here:
```lua
use({
  "NTBBloodbath/zig-tools.nvim",
  -- Load zig-tools.nvim only in Zig buffers
  ft = "zig",
  config = function()
    -- Initialize with default config
    require("zig-tools").setup()
  end,
  requires = {
    {
      "akinsho/toggleterm.nvim",
      config = function()
        require("toggleterm").setup()
      end,
    },
    {
      "nvim-lua/plenary.nvim",
      module_pattern = "plenary.*"
    }
  },
})
```


## Configuration

zig-tools.nvim comes with sane _and opinionated_ defaults for its configurations. These defaults
are the following:
```lua
--- zig-tools.nvim configuration
---@type table
_G.zigtools_config = {
  --- Commands to interact with your project compilation
  ---@type boolean
  expose_commands = true,
  --- Format source code
  ---@type table
  formatter = {
    --- Enable formatting, create commands
    ---@type boolean
    enable = true,
    --- Events to run formatter, empty to disable
    ---@type table
    events = {},
  },
  --- Check for compilation-time errors
  ---@type table
  checker = {
    --- Enable checker, create commands
    ---@type boolean
    enable = true,
    --- Run before trying to compile?
    ---@type boolean
    before_compilation = true,
    --- Events to run checker
    ---@type table
    events = {},
  },
  --- Project compilation helpers
  ---@type table
  project = {
    --- Extract all build tasks from `build.zig` and expose them
    ---@type boolean
    build_tasks = true,
    --- Enable rebuild project on save? (`:ZigLive` command)
    ---@type boolean
    live_reload = true,
    --- Extra flags to be passed to compiler
    ---@type table
    flags = {
      --- `zig build` flags
      ---@type table
      build = {"--prominent-compile-errors"},
      --- `zig run` flags
      ---@type table
      run = {},
    },
    --- Automatically compile your project from within Neovim
    auto_compile = {
      --- Enable automatic compilation
      ---@type boolean
      enable = false,
      --- Automatically run project after compiling it
      ---@type boolean
      run = true,
    },
  },
  --- zig-tools.nvim integrations
  ---@type table
  integrations = {
    --- Third-party Zig packages manager integration
    ---@type table
    package_managers = {"zigmod", "gyro"},
    --- Zig Language Server
    ---@type table
    zls = {
      --- Enable inlay hints
      ---@type boolean
      hints = false,
      --- Manage installation
      ---@type table
      management = {
        --- Enable ZLS management
        ---@type boolean
        enable = false,
        --- Installation path
        ---@type string
        install_path = os.getenv("HOME") .. "/.local/bin",
        --- Source path (where to clone repository when building from source)
        ---@type string
        source_path = os.getenv("HOME") .. "/.local/zig/zls",
      },
    },
  }

  -- Option for toggleterm
  -- see https://github.com/akinsho/toggleterm.nvim
  ---@type table
  terminal = {
    direction = "vertical",
    auto_scroll = true,
    close_on_exit = false,
  },
}
```

> Wanna know why it is a global scope table? Make sure to read the [API](./docs/api.md) document.


## Usage

Once installed and configured, zig-tools.nvim is going to make and run an augroup (`ZigTools`)
with an autocommand for `*.zig` files that sets up `:Zig` command on Zig buffers.

`:Zig` command works with subcommands, that means its usage is something like this:
```vim
" Build project
:Zig build

" Run tests
:Zig task test
```

You can then use this command to create mappings, run autocommands, etc on Zig files.

If you did set `expose_commands` configuration option to `false` in your zig-tools.nvim setup
then `:Zig` command is not going to be available. However, you can still use its functionalities
by directly using zig-tools.nvim commands API.

> You can see full `:Zig` command reference in the [API](./docs/api.md) document.


## FAQ

> Last design mantra says that zig-tools.nvim is not going to get in my way but it can also
> manage zls installation. How does it make sense?

zig-tools.nvim `zls` management works pretty differently from Neovim plugins like lsp-installer.
That means, zig-tools.nvim will only get `zls` from your chosen installation method (gh
releases or build from source) and then move `zls` binary to your `PATH` so you can set up `zls`
yourself by using `nvim-lspconfig` with no weird abstractions.


## License

As all my other projects, zig-tools.nvim is licensed under [GPLv3](./LICENSE) license.
