-- ┌                                                          ┐
-- │  Copyright (c) 2022 NTBBloodbath. All rights reserved.   │
-- │  Use of this source code is governed by a GPL3 license   │
-- │          that can be found in the LICENSE file.          │
-- └                                                          ┘
local zig_tools = {}

local config = require("zig-tools.config")
local cfg = config.get()

local autocmds = require("zig-tools.autocmds")

zig_tools.setup = function(opts)
  cfg = config.set(opts or {})

  -- Set up zig-tools.nvim autocommand to set up `:Zig` command
  autocmds.setup(cfg)
end

return zig_tools
