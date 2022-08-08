---

title: api
description: zig-tools.nvim API documentation
authors: NTBBloodbath
categories: zig-tools.nvim api reference
created: 2022-08-07
version: 0.0.11
---


# API

This document has a full reference to internal _and public_ zig-tools.nvim API.

> Note that some internal stuff isn't completely documented here as each Lua module has internal
> documentation _and annotations_ for functions, tables, etc.


## Modules

This section covers documentation for zig-tools.nvim Lua modules.


### config

This module sets up a global scope table `_G.zigtools_config` with zig-tools.nvim
configurations.

**Private functions**:
- None

**Exposed functions**:
- `set(opts: table)`
    - Set zig-tools.nvim global configuration options

**Depends on**:
- None

**Modules that needs this module to work**:
- All other modules except `utils`


### utils

This module exposes some utility functions that are specific to Zig development environment.

**Private functions**:
- None

**Exposed functions**:
- `is_zig_project() -> boolean`
    - Check if we are in a Zig project workspace
- `get_zig_project_root() -> string|nil`
    - Get Zig project root directory, returns `nil` if not in a Zig project
- `get_source_files() -> table`
    - Get Zig project workspace source code files and `build.zig`

**Depends on**:
- `plenary.scandir` module (`nvim-lua/plenary.nvim` plugin)

**Modules that needs this module to work**:
- `commands` module


### commands

This module exposes all zig-tools.nvim commands as functions and `:Zig` command as a wrapper for
these functions.

**Private functions**:
- None

**Exposed functions**:
- `build()`
    - Build current project
- `run(file_mode: boolean)`
    - Run current project or current file if `file_mode` parameter is `true`
- `fmt(files: table)`
    - Format Zig source code files
- `check(files: table)`
    - Check for compilation-time errors in Zig source code files
- `project.task(task_name: string?)`
    - Run a specific project build task, open a prompt if `task_name` parameter is `nil`
- `init(bufnr: number)`
    - Initialize zig-tools.nvim commands on `bufnr` buffer

**Depends on**:
- `utils` module
- `config` module
- `toggleterm.terminal` module (`akinsho/toggleterm.nvim` plugin)

**Modules that needs this module to work**:
- `autocmds` module


### autocmds

This module sets up a augroup called `ZigTools` that has the following autocommands inside:
- Opt-in creation of `:Zig` command in `*.zig` files

**Private functions**:
- None

**Exposed functions**:
- `setup()`
    - Sets up zig-tools.nvim augroup and autocommands

**Depends on**:
- `config` module
- `commands` module

**Modules that needs this module to work**:
- `zig-tools` (core) module


## Zig command

This section covers documentation for zig-tools.nvim `:Zig` command.


### Available subcommands

`:Zig` command does use subcommands in order to work, some of these subcommands are available
only when certain configuration options are enabled (opt-in). Its subcommands are the following:


#### build

Build current project.

**Takes arguments?**
- No

**Requires a feature?**
- No

**Equivalent to**:
- `zig build`

**Examples**:
```vim
:Zig build
```


#### run

Compile and run current project or current `file`.

**Takes arguments?**
- `file` (optional, literal `file` word)

**Requires a feature?**
- No

**Equivalent to**:
- `zig run` (when `file` argument is passed)
- `zig build run`

**Examples**:
```vim
" Compile and run project
:Zig run

" Compile and run current file
:Zig run file
```


#### fmt

Format Zig source code files.

**Takes arguments?**
- Any (optional, all current project source code files if no arguments were passed)
  
**Requires a feature?**
- `config.formatter.enable = true`

**Equivalent to**:
- `zig fmt`

**Examples**:
```vim
" Format all current project source code files + build.zig
:Zig fmt

" Format current file (literal file word)
:Zig fmt file

" Format X files
:Zig fmt file1.zig file2.zig ...

" Format current file and X additional files
:Zig fmt file file1.zig file2.zig ...
```


#### check

Check for compilation-time errors in Zig source code files.

**Takes arguments?**
- Any (optional, all current project source code files if no arguments were passed)
  
**Requires a feature?**
- `config.checker.enable = true`

**Equivalent to**:
- `zig ast-check`

**Examples**:
```vim
" Check all current project source code files + build.zig
:Zig check

" Check current file (literal file word)
:Zig check file

" Check X files
:Zig check file1.zig file2.zig ...

" Check current file and X additional files
:Zig check file file1.zig file2.zig ...
```


#### task

Run a specific project build task.

**Takes arguments?**
- `task_name` (optional, open a prompt if `task_name` argument is `nil`)

**Requires a feature?**
- `config.project.build_tasks = true`

**Equivalent to**:
- `zig build <task>`

**Examples**:
```vim
" Open a prompt to select a build.zig task and run it
:Zig task

" Run project tests
:Zig task test
```