-- ┌                                                          ┐
-- │  Copyright (c) 2022 NTBBloodbath. All rights reserved.   │
-- │  Use of this source code is governed by a GPL3 license   │
-- │          that can be found in the LICENSE file.          │
-- └                                                          ┘
local utils = {}

--- Check if we are in a Zig project workspace
---@return boolean
utils.is_zig_project = function()
	local build_file = vim.fn.findfile("build.zig", vim.fn.expand("%:p:h") .. ";")
	return build_file ~= ""
end

--- Get current Zig project root, returns `nil` if not in a Zig project
---@return string|nil
utils.get_zig_project_root = function()
	if not utils.is_zig_project() then
		return nil
	end

	local build_file = vim.fn.findfile("build.zig", vim.fn.expand("%:p:h") .. ";")
	local project_root
	if build_file == "build.zig" then
		project_root = "./"
	else
		project_root = build_file:gsub("/build.zig", "")
	end
	return project_root
end

return utils
