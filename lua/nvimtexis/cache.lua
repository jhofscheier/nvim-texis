-- Helper functions administrating nvimtexis' sever list cache.

local uv = vim.loop

local cache = {}

cache.filename = vim.api.nvim_call_function('stdpath', {'cache'}) ..
														'/nvim_servernames.log'
cache.nvimtexis_vise_cmd = 'edit'

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

-- reads servernames from cache file
-- returns multi-line string
-- each line represents a sever address
function cache.servernames()
	local fd = assert(uv.fs_open(cache.filename, "r", 420))
	local stat = assert(uv.fs_fstat(fd))
	local servers = assert(uv.fs_read(fd, stat.size, 0))
	assert(uv.fs_close(fd))

	return servers
end

-- Functions to administrate the location of the 
-- cache file to save available servers
-- function cache.cache_path(name)
-- 	local root = cache.cache_root()
-- 	if vim.api.nvim_call_function('isdirectory', {root}) == 0 then
-- 		os.execute('mkdir -p ' .. root)
-- 	end
-- 	return root .. '/' .. name
-- end

-- Load cached list of servers and check which ones are still online.
-- Add this nvim instance to list of servers. Saver list to cache file.
function cache.prune_servernames()
	-- Load servernames from file
	local servers_file = io.open(cache.filename, "r")
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
	write_to_file(cache.filename, available_servernames)
end


return cache
