-- ┌                                                          ┐
-- │  Copyright (c) 2022 NTBBloodbath. All rights reserved.   │
-- │  Use of this source code is governed by an MIT license   │
-- │          that can be found in the LICENSE file.          │
-- └                                                          ┘
local autocmds = {}

local commands = require("zig-tools.commands")

--- Set up ZigTools autocommands group and set `:Zig` command
autocmds.setup = function()
	-- Fast return if user does not want to expose commands
	if not _G.zigtools_config.expose_commands then
		return
	end

  local zig_tools_augroup = vim.api.nvim_create_augroup("ZigTools", {})
  vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    group = zig_tools_augroup,
    pattern = "*.zig",
    callback = function(args)
      commands.init(args.buf)
    end,
    desc = "Set up zig-tools.nvim commands",
  })
end

return autocmds
