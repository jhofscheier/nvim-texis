-- Functions for pdf-viewers to communicate with neovim

local cache = require('nvimtexis.cache')

local caller = {}

---Sends an rpc request setting the line number in a particular file in all
---active Neovim instances. Line number and filename are extracted from `args`.
---@param args string # expected format 'filename' 'line number' where quotes
---                     can be left out, single or double quotes
function caller.inverse_search(args)
	---@type string, string
	local _, filename, _, line = args:match([[(["']?)(.+)%1 (["']?)(%d+)%3]])
	if filename ~= '' and line ~= '' then
		line = tonumber(line)
		if line > 0 and filename and filename ~= '' then
			---@type boolean, string, integer
			local ok, servers, socket
			ok, servers = pcall(cache.servernames)
			-- if opening servernames file failed then exit
			if not ok then
				vim.cmd('quitall!')
			end
			for server in servers:gmatch("(.-)\n")  do
				---@type boolean, integer
				ok, socket = pcall(vim.api.nvim_call_function,
								   'sockconnect',
								   {'pipe', server, {rpc = 1}})
				if ok then

					vim.rpcrequest(
					   socket,
					   'nvim_exec_lua',
					   [[return require('nvimtexis.view').inverse_search(...)]],
					   { filename, line, })
					vim.api.nvim_call_function('chanclose', {socket})
				end
			end
		end
	end
	vim.cmd('quitall!')
end

return caller
