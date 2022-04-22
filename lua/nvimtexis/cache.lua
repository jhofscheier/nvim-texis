-- Helper functions administrating nvimtexis' sever list cache.

local nvimtexis_cache = {}

nvimtexis_cache.servernames = ''

-- write list of strings [data] to file [file_name]
-- file_name:	string representing valid file name
-- data:		table of strings
local function write_to_file(file_name, data)
	local f = io.open(file_name, "w")
	if f ~= nil then
		for _, entry in ipairs(data) do
			f:write(entry, "\n")
		end
		f:close()
	end
end

-- Function returns the root directory for the nvimtexis cache.
-- The following priority is used:
-- 1. Return user-defined value 'nvimtexis_cache_root' if exists.
-- 2. Return $XDG_CACHE_HOME if defined.
-- 3. Fall back to '$HOME/.cache' if none of the above works.
function nvimtexis_cache.cache_root()
	-- 1. check if user-defined value exists
	if vim.g.nvimtexis_cache_root then
		return vim.g.nvimtexis_cache_root
	end

	-- 2. Is $XDG_CACHE_HOME defined?
	local xdg_cache_home = os.getenv('XDG_CACHE_HOME')
	if xdg_cache_home then
		return xdg_cache_home .. '/nvimtexis'
	end

	-- 3. Fall back to '$HOME/.cache'
	return os.getenv('HOME') .. '/.cache/nvimtexis'
end

-- Functions to administrate the location of the 
-- cache file to save available servers
function nvimtexis_cache.cache_path(name)
	local root = nvimtexis_cache.cache_root()
	if vim.api.nvim_call_function('isdirectory', {root}) == 0 then
		os.execute('mkdir -p ' .. root)
	end
	return root .. '/' .. name
end

-- Load cached list of servers and check which ones are still online.
-- Add this nvim instance to list of servers. Saver list to cache file.
function nvimtexis_cache.prune_servernames()
	-- Load servernames from file
	local servers_file = io.open(nvimtexis_cache.servernames, "r")
	local servers = {}
	if servers_file ~= nil then
		for line in servers_file:lines() do
			servers[line] = 1
		end
		servers_file:close()
	end
	-- add this nvim instance to the list (do nothing if already exists)
	if servers[vim.v.servername] == nil then
		servers[vim.v.servername] = 1
	end

	-- Check which servers are still online
	local available_servernames = {}
	for server, _ in pairs(servers) do
		local status_ok, socket = pcall(vim.api.nvim_call_function,
										'sockconnect',
										{'pipe', server}) 
		if status_ok then
			table.insert(available_servernames, server)
			vim.api.nvim_call_function('chanclose', {socket})
		end
	end
	
	-- Write the pruned list to file
	write_to_file(nvimtexis_cache.servernames, available_servernames)
end

function nvimtexis_cache.init_servernames()
	nvimtexis_cache.servernames =
							nvimtexis_cache.cache_path('nvim_servernames.log')
end

nvimtexis_cache.nvimtexis_vise_cmd = 'edit'

return nvimtexis_cache
