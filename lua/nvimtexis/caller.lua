-- Functions for pdf-viewers to communicate with neovim

local caller = {}

local cache = require('nvimtexis.cache')

function caller.inverse_search(filename, line)
	if line > 0 and filename and filename ~= '' then
		local ok, servers, socket
		ok, servers = pcall(cache.servernames)
		-- if opening servernames file failed then exit
		if not ok then
			vim.cmd('quitall!')
		end
		for server in servers:gmatch("(.-)\n") do
			ok, socket = pcall(vim.api.nvim_call_function,
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
	end
	vim.cmd('quitall!')
end

return caller
