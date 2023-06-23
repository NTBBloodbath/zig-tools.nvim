-- ┌                                                          ┐
-- │  Copyright (c) 2022 NTBBloodbath. All rights reserved.   │
-- │  Use of this source code is governed by a GPL3 license   │
-- │          that can be found in the LICENSE file.          │
-- └                                                          ┘
local zls = {}
zls.management = {}

local terminal = require("toggleterm.terminal").Terminal

--- Check if ZLS is installed on system's PATH
---@return boolean
local function is_zls_installed()
	return vim.fn.executable("zls") == 1
end

local function get_download_engine()
	-- Prefer wget over cURL
	if vim.fn.executable("wget") == 1 then
		return "wget"
	elseif vim.fn.executable("curl") == 1 then
		return "curl"
	end
end

zls.install = function(force)
	if is_zls_installed() and not force then
		vim.notify(
			"[zig-tools.nvim] ZLS is already installed in your system's PATH. If you want to force installation pass 'force' argument as 'true' to this function",
			vim.log.levels.ERROR
		)
		return
	end

	local config = _G.zigtools_config
	vim.ui.select(
		{ "GitHub releases", "Build from source" },
		{ prompt = "Select an installation method for ZLS:" },
		function(choice)
			if choice then
				if choice == "GitHub releases" then
					-- local download_engine = get_download_engine()
					print("WIP")
				elseif choice == "Build from source" then
					local build = terminal:new(vim.tbl_extend("force", config.terminal, {
						direction = "horizontal",
					}))
					build:toggle()
					-- Create required directories if needed then
					-- clone repository, build and configure zls and copy it to PATH
					build:send([[
    		    [ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin" && CREATED_LOCAL_BIN=true \
    		      && git clone --recurse-submodules --depth 1 https://github.com/zigtools/zls.git "$HOME/.local/zig/zls" \
    		      && cd "$HOME/.local/zig/zls" \
    		      && zig build -Drelease-safe \
    		      && ./zig-out/bin/zls "$HOME/.local/bin/zls" \
    		      && echo "Installation done!" \
    		      && [ -z "$CREATED_LOCAL_BIN" ] \
      		      && echo "Now add $HOME/.local/bin to your PATH and reload your shell to start using zls"
    		  ]])
				end
			else
				vim.notify("\n[zig-tools.nvim] Cancelled zls installation", vim.log.levels.WARN)
			end
		end
	)
end

return zls
