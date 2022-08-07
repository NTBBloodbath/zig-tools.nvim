-- ┌                                                          ┐
-- │  Copyright (c) 2022 NTBBloodbath. All rights reserved.   │
-- │  Use of this source code is governed by an MIT license   │
-- │          that can be found in the LICENSE file.          │
-- └                                                          ┘
local commands = {}

commands.project = {}
commands.zls = {}

--- Build current project
commands.build = function()
	print("zig build")
end

--- Run current project or current file if `file_mode` argument is `true`
---@param file_mode boolean If should run current file or project
commands.run = function(file_mode)
	if file_mode then
		print("zig run")
	else
		print("zig build run")
	end
end

--- Format Zig source code files
---@param files table Files to be formatted, current buffer is used if files table is empty
commands.fmt = function(files)
	-- If no files were passed as argumentd then use current buffer
	if vim.tbl_isempty(files) then
		table.insert(files, vim.api.nvim_buf_get_name(0))
	end

	-- Avoid using a for loop and iterating over files table if it only contains one file
	-- to gain some small performance improvements
	if #files == 1 then
		print("zig fmt " .. files[1])
	else
		for _, file in ipairs(files) do
			print("zig fmt " .. file)
		end
	end
end

--- Check for compilation-time errors in Zig source code files
---@param files table Files to be checked, current buffer is used if files table is empty
commands.check = function(files)
	-- If no files were passed as argumentd then use current buffer
	if vim.tbl_isempty(files) then
		table.insert(files, vim.api.nvim_buf_get_name(0))
	end

	-- Avoid using a for loop and iterating over files table if it only contains one file
	-- to gain some small performance improvements
	if #files == 1 then
		print("zig ast-check " .. files[1])
	else
		for _, file in ipairs(files) do
			print("zig ast-check " .. file)
		end
	end
end

--- Initialize zig-tools.nvim commands
---@param config table zig-tools.nvim configuration
---@param bufnr number Zig buffer number
commands.init = function(config, bufnr)
	-- Fast return if user does not want to expose commands
	-- TODO: move this small conditional logic to autocommands module once its made
	if not config.expose_commands then
		return
	end

	local cmds = {
		build = commands.build,
		run = commands.run,
	}

	-- TODO: use this table to conditionally add new entries to cmds table
	local enabled_cmds = {
	  formatter = config.formatter.enable,
		checker = config.checker.enable,
		project = {
			tasks = config.project.build_tasks,
			live_reload = config.project.live_reload,
		},
		integrations = {
			package_managers = #config.integrations.package_managers ~= 0,
			zls = {
				hints = config.integrations.zls.hints,
				management = config.integrations.zls.management.enable,
			},
		},
	}

  -- Add opt-in commands if their features are enabled
  if enabled_cmds.formatter then
    vim.tbl_extend("keep", cmds, {fmt = commands.fmt})
  end
  if enabled_cmds.checker then
    vim.tbl_extend("keep", cmds, {check = commands.check})
  end
  -- if enabled_cmds.project.tasks then
  --   vim.tbl_extend("keep", cmds, {task = commands.project.task})
  -- end
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
			local command = cmds[subcmd]
			if subcmd == "build" then
  			command()
  		elseif subcmd == "run" then
  		  if args[1] == "file" then
  		    command(true)
  		  else
  		    command(false)
  		  end
  		elseif vim.tbl_contains({"fmt", "check"}, subcmd) then
  		  command(args)
  		end
		else
			vim.notify("Invalid subcommand '" .. subcmd .. "' provided", vim.log.levels.ERROR)
		end
	end, {
		nargs = "+",
		desc = "Zig develooment tools",
	})
end

return commands
