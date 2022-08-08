-- ┌                                                          ┐
-- │  Copyright (c) 2022 NTBBloodbath. All rights reserved.   │
-- │  Use of this source code is governed by a GPL3 license   │
-- │          that can be found in the LICENSE file.          │
-- └                                                          ┘
local utils = {}

local scan = require("plenary.scandir")

--- Check if we are in a Zig project workspace
---@return boolean
utils.is_zig_project = function()
	---@diagnostic disable-next-line
	local build_file = vim.fn.findfile("build.zig", vim.fn.expand("%:p:h") .. ";")
	return build_file ~= ""
end

--- Get current Zig project root, returns `nil` if not in a Zig project
---@return string|nil
utils.get_zig_project_root = function()
	if not utils.is_zig_project() then
		return nil
	end

	---@diagnostic disable-next-line
	local build_file = vim.fn.findfile("build.zig", vim.fn.expand("%:p:h") .. ";")
	local project_root
	if build_file == "build.zig" then
		project_root = "./"
	else
		project_root = build_file:gsub("/build.zig", "")
	end
	return project_root
end

--- Get all Zig project workspace source code files
---@return table
utils.get_source_files = function()
	if not utils.is_zig_project() then
		return {}
	end

	local project_workspace = utils.get_zig_project_root()
	local project_build_file, project_source_dir
	if project_workspace then
	  if project_workspace:sub(#project_workspace) == "/" then
	    project_build_file = project_workspace .. "build.zig"
	    project_source_dir = project_workspace .. "src"
	  else
	    project_build_file = project_workspace .. "/build.zig"
	    project_source_dir = project_workspace .. "/src"
	  end
	end
	---@diagnostic disable-next-line
	return vim.tbl_extend("force", { project_build_file }, scan.scan_dir(project_source_dir, { source_pattern = "*.zig" }))
end

return utils
