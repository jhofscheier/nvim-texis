-- Helper functions administrating nvimtexis' sever list cache.

local uv = vim.loop

local cache = {}

cache.filename = vim.api.nvim_call_function('stdpath', {'cache'}) ..
														'/nvim_servernames.log'
cache.nvimtexis_vise_cmd = 'edit'

-- reads servernames from cache file
-- returns multi-line string
-- each line represents a sever address
function cache:servernames()
	local fd = assert(uv.fs_open(self.filename, "r", 420))
	local stat = assert(uv.fs_fstat(fd))
	local servers = assert(uv.fs_read(fd, stat.size, 0))
	assert(uv.fs_close(fd))

	return servers
end

-- write table of strings [data] to servers file
function cache:write(data)
	local fd = assert(uv.fs_open(self.filename, 'w', 438))
	-- cache file needs to end with empty line
	assert(uv.fs_write(fd, table.concat(data, '\n') .. '\n '))
	assert(uv.fs_close(fd))
end

-- check if string [str] is in list of strings [lst]
local function in_list(str, lst)
	for _, el in ipairs(lst) do
		if el == str then
			return true
		end
	end
	return false
end

-- load cached list of servers and check which ones are still online.
-- add this nvim instance to list of servers. Saver list to cache file.
function cache:prune_servernames()
	local active_servers = {}
	local n = 0
	-- Load servernames from file
	local ok, servers_str = pcall(self.servernames, self)

	if ok then
		-- check which servers are still active
		for server in servers_str:gmatch("(.-)\n") do
			local ok, socket = pcall(vim.api.nvim_call_function,
									 'sockconnect',
									 {'pipe', server}) 
			if ok then
				n=n+1
				active_servers[n] = server
				vim.api.nvim_call_function('chanclose', {socket})
			end
		end
	end
	
	-- add this nvim instance to the list (do nothing if already exists)
	if not in_list(vim.v.servername, active_servers) then
		active_servers[n+1] = vim.v.servername
	end

	-- write the pruned list to file
	self:write(active_servers)
end

return cache
