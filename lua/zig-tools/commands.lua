-- ┌                                                          ┐
-- │  Copyright (c) 2022 NTBBloodbath. All rights reserved.   │
-- │  Use of this source code is governed by a GPL3 license   │
-- │          that can be found in the LICENSE file.          │
-- └                                                          ┘
local commands = {}
commands.project = {}
commands.zls = {}

local utils = require("zig-tools.utils")

local terminal = require("toggleterm.terminal").Terminal

--- Build current project
commands.build = function()
	if not utils.is_zig_project() then
		vim.notify(
			"[zig-tools.nvim] Tried to run `:Zig build` outside a Zig project. "
				.. "Run `zig init-exe` in your project root directory if your project is an executable or `zig init-lib` if a library "
				.. "or make sure you're currently in your project's root directory",
			vim.log.levels.ERROR
		)
		return
	end

	local config = _G.zigtools_config

	local cmd = "zig build"
	---@diagnostic disable-next-line
	local flags = config.project.flags.build
	if not vim.tbl_isempty(flags) then
		cmd = cmd .. " " .. table.concat(flags, " ")
	end

	local build = terminal:new(vim.tbl_extend("force", config.terminal, {
		cmd = cmd,
	}))
	build:toggle(50)
end

--- Run current project or current file if `file_mode` argument is `true`
---@param file_mode boolean If should run current file or project
commands.run = function(file_mode)
	local cmd = "zig build run"
	if file_mode then
		local current_file = vim.api.nvim_buf_get_name(0)
		cmd = "zig run " .. current_file
	end

	if cmd == "zig build run" and not utils.is_zig_project() then
		vim.notify(
			"[zig-tools.nvim] Tried to run `:Zig run` outside a Zig project. "
				.. "Run `zig init-exe` in your project root directory if your project is an executable or `zig init-lib` if a library "
				.. "or make sure you're currently in your project's root directory",
			vim.log.levels.ERROR
		)
		return
	end

	local config = _G.zigtools_config
	local run = terminal:new(vim.tbl_extend("force", config.terminal, {
		cmd = cmd,
	}))
	run:toggle(50)
end

--- Format Zig source code files
---@param files table Files to be formatted, all project source files are used if files table is empty
commands.fmt = function(files)
	-- If no files were passed as argumentd then format all project source files
	if vim.tbl_isempty(files) then
		files = utils.get_source_files()
	end

	-- If only files table value is `file` then use current buffer
	if files[1] == "file" then
		files[1] = vim.api.nvim_buf_get_name(0)
	end

	-- Avoid using a for loop and iterating over files table if it only contains one file
	-- to gain some small performance improvements
	if #files == 1 then
		local fmt = terminal:new(vim.tbl_extend("force", config.terminal, {
			cmd = "zig fmt " .. files[1],
			close_on_exit = true,
		}))
		fmt:spawn()
		fmt:toggle(30)
	else
		-- We spawn a default terminal with no custom command to send them through `terminal:send(cmd)`
		local fmt = terminal:new(vim.tbl_extend("force", config.terminal, {
			close_on_exit = true,
		}))
		fmt:toggle(30)
		for _, file in ipairs(files) do
			fmt:send("zig fmt " .. file)
		end
		fmt:send("exit")
	end
end

--- Check for compilation-time errors in Zig source code files
---@param files table Files to be checked,all project source files are used if files table is empty
commands.check = function(files)
	-- If no files were passed as argumentd then format all project source files
	if vim.tbl_isempty(files) then
		files = utils.get_source_files()
	end

	-- If only files table value is `file` then use current buffer
	if files[1] == "file" then
		files[1] = vim.api.nvim_buf_get_name(0)
	end

	-- Avoid using a for loop and iterating over files table if it only contains one file
	-- to gain some small performance improvements
	if #files == 1 then
		local check = terminal:new(vim.tbl_extend("force", config.terminal, {
			cmd = "zig ast-check " .. files[1],
		}))
		check:toggle(50)
	else
		-- We spawn a default terminal with no custom command to send them through `terminal:send(cmd)`
		local check = terminal:new(config.terminal)
		check:toggle(50)
		for _, file in ipairs(files) do
			check:send("zig ast-check " .. file)
		end
	end
end

--- Run a specific project build task, open a prompt if `task_name` parameter is `nil`
---@param task_name string? An optional task name
commands.project.task = function(task_name)
	if not utils.is_zig_project() then
		vim.notify(
			"[zig-tools.nvim] Tried to run `:Zig task` outside a Zig project. "
				.. "Run `zig init-exe` in your project root directory if your project is an executable or `zig init-lib` if a library "
				.. "or make sure you're currently in your project's root directory",
			vim.log.levels.ERROR
		)
		return
	end

	local project_root = utils.get_zig_project_root()
	local build_tasks = vim.fn.systemlist(string.format("cat %s/build.zig", project_root) .. [[ |
		rg --only-matching 'b\.step\("\w+",\s".*"\);' |
		  rg --only-matching '"\w+",\s".*"' |
		    tr -d '"']])
	local tasks = {}

	-- Avoid using a for loop and iterating over tasks table if it only contains one task
	-- to gain some small performance improvements
	if #build_tasks == 1 then
		local task_tbl = vim.split(build_tasks[1], ", ")
		---@diagnostic disable-next-line
		tasks = vim.tbl_extend("keep", tasks, { [task_tbl[1]] = task_tbl[2] })
	else
		for _, task in ipairs(build_tasks) do
			local task_tbl = vim.split(task, ", ")
			---@diagnostic disable-next-line
			tasks = vim.tbl_extend("keep", tasks, { [task_tbl[1]] = task_tbl[2] })
		end
	end

	-- If a task name was provided then try to run it, otherwise open an interactive prompt to select a task
	local task_names = vim.tbl_keys(tasks)
	if task_name then
		if vim.tbl_contains(task_names, task_name) then
			local run_task = terminal:new(vim.tbl_extend("force", config.terminal, {
				---@diagnostic disable-next-line
				cmd = "zig build " .. task_name .. " " .. table.concat(config.project.flags.build, " "),
			}))
			run_task:toggle(50)
		else
			local error_msg = string.format(
				"[zig-tools.nvim] Invalid task '%s' provided. Available tasks:\n",
				task_name
			)
			for task, desc in pairs(tasks) do
				error_msg = error_msg .. string.format("- %s, %s\n", task, desc)
			end
			vim.notify(error_msg, vim.log.levels.ERROR)
		end
	else
		vim.ui.select(task_names, {
			prompt = "Select a task:",
			format_item = function(item)
				---@diagnostic disable-next-line
				return item .. ", " .. tasks[item]
			end,
		}, function(task)
			if task then
				local run_task = terminal:new(vim.tbl_extend("force", config.terminal, {
					---@diagnostic disable-next-line
					cmd = "zig build " .. task .. " " .. table.concat(config.project.flags.build, " "),
				}))
				run_task:toggle(50)
			else
				vim.notify("\n[zig-tools.nvim] Cancelled `:Zig task` command", vim.log.levels.WARN)
			end
		end)
	end
end

--- Initialize zig-tools.nvim commands on `bufnr` buffer
---@param bufnr number Zig buffer number
commands.init = function(bufnr)
	local config = _G.zigtools_config
	local cmds = {
		build = commands.build,
		run = commands.run,
	}

	local enabled_cmds = {
		---@diagnostic disable-next-line
		formatter = config.formatter.enable,
		---@diagnostic disable-next-line
		checker = config.checker.enable,
		project = {
			---@diagnostic disable-next-line
			tasks = config.project.build_tasks,
			---@diagnostic disable-next-line
			live_reload = config.project.live_reload, -- Not implemented yet
		},
		integrations = { -- Not implemented yet
			---@diagnostic disable-next-line
			package_managers = #config.integrations.package_managers ~= 0,
			zls = {
				-- NOTE: this is not going to be implemented in a while, see config.lua comments
				---@diagnostic disable-next-line
				hints = config.integrations.zls.hints,
				---@diagnostic disable-next-line
				management = config.integrations.zls.management.enable,
			},
		},
	}

	-- Add opt-in commands if their features are enabled
	if enabled_cmds.formatter then
		---@diagnostic disable-next-line
		cmds = vim.tbl_extend("keep", cmds, { fmt = commands.fmt })
	end
	if enabled_cmds.checker then
		---@diagnostic disable-next-line
		cmds = vim.tbl_extend("keep", cmds, { check = commands.check })
	end
	if enabled_cmds.project.tasks then
		---@diagnostic disable-next-line
		cmds = vim.tbl_extend("keep", cmds, { task = commands.project.task })
	end
	-- if enabled_cmds.project.live_reload then
	--   vim.tbl_extend("keep", cmds, {live_reload = commands.project.live_reload})
	-- end
	-- if enabled_cmds.integrations.zls.hints then
	--   vim.tbl_extend("keep", cmds, {hints = commands.zls.hints})
	-- end
	-- if enabled_cmds.integrations.zls.management then
	--   vim.tbl_extend("keep", cmds, {install = commands.zls.install})
	-- end

	-- NOTE: we use buffer variant as we are going to set commands by using
	--       an autocommand on BufEnter event to make Zig commands only
	--       available on Zig buffers.
	vim.api.nvim_buf_create_user_command(bufnr, "Zig", function(args_tbl)
		local args = args_tbl.fargs
		local subcmd = args[1]
		table.remove(args, 1)

		if vim.tbl_contains(vim.tbl_keys(cmds), subcmd) then
			---@diagnostic disable-next-line
			local command = cmds[subcmd]
			if subcmd == "build" then
				command()
			elseif subcmd == "run" then
				if #args > 1 then
					vim.notify(
						"[zig-tools.nvim] `:Zig` subcommand 'run' only takes one parameter",
						vim.log.levels.ERROR
					)
					return
				end
				if args[1] == "file" then
					command(true)
				elseif args[1] == nil then
					command(false)
				else
					vim.notify(
						"[zig-tools.nvim] Invalid parameter '" .. args[1] .. "' passed to `:Zig run` subcommand",
						vim.log.levels.ERROR
					)
				end
			elseif vim.tbl_contains({ "fmt", "check" }, subcmd) then
				command(args)
			elseif subcmd == "task" then
				if #args > 1 then
					vim.notify(
						"[zig-tools.nvim] `:Zig` subcommand 'task' only takes one parameter",
						vim.log.levels.ERROR
					)
					return
				end
				command(args[1])
			end
		else
			vim.notify(
				"[zig-tools.nvim] Invalid subcommand '" .. subcmd .. "' provided for `:Zig`",
				vim.log.levels.ERROR
			)
		end
	end, {
		nargs = "+",
		desc = "Zig development tools",
	})
end

return commands

-- vim: foldlevel=99
