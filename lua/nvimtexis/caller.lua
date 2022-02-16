-- Functions for pdf-viewers to communicate with neovim

local caller = {}

local cache = require('nvimtexis.cache')

-- Initialise cache.servernames 
cache.init_servernames()

function caller.inverse_search(line, file_name)
	if line > 0 and file_name and file_name ~= '' then
		local servers_file = io.open(cache.servernames, "r")
		if not servers_file then	
			vim.cmd('quitall!')
		end
		for server in servers_file:lines() do
			local status_ok, socket = pcall(vim.api.nvim_call_function,
										    'sockconnect',
											{'pipe', server, {rpc = 1}})
			if status_ok then
				vim.rpcnotify(socket,
							  'nvim_command',
							  "lua require('nvimtexis.view').inverse_search(" .. tostring(line) .. ", '" .. file_name .. "')")

				vim.api.nvim_call_function('chanclose', {socket})
			end
		end
		servers_file:close()
	end
	vim.cmd('quitall!')
end

return caller
