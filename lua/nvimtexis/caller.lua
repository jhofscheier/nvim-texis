-- Functions for pdf-viewers to communicate with neovim

local caller = {}

local cache = require('nvimtexis.cache')

-- Initialise cache.servernames 
cache.init_servernames()

function caller.inverse_search(filename, line)
	if line > 0 and filename and filename ~= '' then
		local servers_file = io.open(cache.servernames, "r")
		if not servers_file then	
			vim.cmd('quitall!')
		end
		for server in servers_file:lines() do
			local ok, socket = pcall(vim.api.nvim_call_function,
								     'sockconnect',
									 {'pipe', server, {rpc = 1}})
			if ok then
				vim.rpcrequest(
					socket,
					'nvim_exec_lua',
					[[return require('nvimtexis.view').inverse_search(...)]],
					{
						filename,
						line,
					}
				)
				vim.api.nvim_call_function('chanclose', {socket})
			end
		end
		servers_file:close()
	end
	vim.cmd('quitall!')
end

return caller
