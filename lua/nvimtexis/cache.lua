-- Helper functions administrating nvimtexis' sever list cache.

local uv = vim.loop
local Config = require("nvimtexis.config")

local cache = {}

---reads servernames from cache file
---@return string # multi-line string, each line represents a sever address
function cache.servernames()
	---@type integer
	local fd = assert(uv.fs_open(Config.filename, "r", 420))
	---@type table
	local stat = assert(uv.fs_fstat(fd))
	---@type string
	local servers = assert(uv.fs_read(fd, stat.size, 0))
	assert(uv.fs_close(fd))

	return servers
end

---write table of strings [data] to servers file
---@param data string[]
function cache.write(data)
	---@type integer
	local fd = assert(uv.fs_open(Config.filename, 'w', 438))
	-- cache file needs to end with empty line
	assert(uv.fs_write(fd, table.concat(data, '\n') .. '\n '))
	assert(uv.fs_close(fd))
end

---check if string `str` is in list of strings `lst`
---@param str string
---@param lst string[]
---@return boolean
local function in_list(str, lst)
	for _, el in ipairs(lst) do
		if el == str then
			return true
		end
	end
	return false
end

---Load cached list of servers and check which ones are still online. Add this
---nvim instance to list of servers. Saver list to cache file.
function cache.prune_servernames()
	---@type string[]
	local active_servers = {}
	---@type integer
	local n = 0
	-- Load servernames from file
	---@type boolean, string|nil
	local ok_servernames, servers_str = pcall(cache.servernames)

	if ok_servernames then
		-- check which servers are still active
		---@cast servers_str string
		for server in vim.split(servers_str, "\n") do
			---@type boolean, integer
			local ok, socket = pcall(
				vim.api.nvim_call_function,
				'sockconnect',
				{
					'pipe',
					server
				}
			)
			if ok then
				n = n + 1
				active_servers[n] = server
				vim.api.nvim_call_function('chanclose', { socket })
			end
		end
	end

	-- add this nvim instance to the list (do nothing if already exists)
	if not in_list(vim.v.servername, active_servers) then
		active_servers[n + 1] = vim.v.servername
	end

	-- write the pruned list to file
	cache.write(active_servers)
end

---Sets autocommand to prune servernames cache each time a new tex or bib file
---is opened.
function cache.autocmd_servernames()
	local augroup_id = vim.api.nvim_create_augroup(
		'NvimTeXInverseSearch',
		{
			clear = true
		}
	)
	vim.api.nvim_create_autocmd(
		{ 'FileType' },
		{
			pattern = { 'tex', 'bib', 'plaintex' },
			callback = function()
				cache.prune_servernames()
			end,
			group = augroup_id,
			desc = 'nvimtexis: prune servernames',
		}
	)
end

return cache
