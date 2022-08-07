-- ┌                                                          ┐
-- │  Copyright (c) 2022 NTBBloodbath. All rights reserved.   │
-- │  Use of this source code is governed by an MIT license   │
-- │          that can be found in the LICENSE file.          │
-- └                                                          ┘
local commands = {}

commands.build = function()
	print("zig build")
end

commands.run = function(file_mode)
	if file_mode then
		print("zig run")
	else
		print("zig build run")
	end
end

commands.init = function(config, bufnr)
	-- Fast return if user does not want to expose commands
	if not config.expose_commands then
		return
	end

	local cmds = {
		build = commands.build,
		run = commands.run,
	}

	-- TODO: use this table to conditionally add new entries to cmds table
	local enabled_cmds = {
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

	-- NOTE: we use buffer variant as we are going to set commands by using
	--       an autocommand on BufEnter event to make Zig commands only
	--       available on Zig buffers.
	vim.api.nvim_buf_create_user_command(bufnr, "Zig", function(args_tbl)
		local args = args_tbl.fargs
		local subcmd = args[1]
		table.remove(args, 1)

		if vim.tbl_contains(vim.tbl_keys(cmds), subcmd) then
			local command = cmds[subcmd]
			command()
		else
			vim.notify("Invalid subcommand '" .. subcmd .. "' provided", vim.log.levels.ERROR)
		end
	end, {
		nargs = "+",
		desc = "Zig develooment tools",
	})
end

return commands
