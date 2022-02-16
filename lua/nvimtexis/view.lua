-- Functions for inverse search used by the neovim
-- instance that has loaded the tex-file.

local view = {}

local cache = require('nvimtexis.cache')

function view.inverse_search(line, file_name)
	local file = vim.api.nvim_call_function('resolve', {file_name})
	if vim.api.nvim_call_function('mode', {}) == 'i' then
		vim.cmd('stopinsert')
	end

	if not vim.api.nvim_buf_is_loaded(file) then
		if vim.api.nvim_call_function('filereadable', {file}) == 1 then
			local status_ok, _ = pcall(vim.cmd,
									   cache.nvimtexis_vise_cmd .. ' ' .. file)
			if not status_ok then
				print("Reverse goto failed; command error: ",
					  cache.nvimtexis_vise_cmd, file)
				return -3
			end
		else
			print("Reverse goto failed; file not readable: '", file, "'")
			return -4
		end
	end

	-- Get buffer, window, and tab numbers
	-- * If tab/window exists, switch to it/them
	local bufnr = vim.api.nvim_buf_get_number(file)
	local winid = vim.api.nvim_call_function('win_findbuf', {bufnr})
	-- if exactly one window view open for buffer
	if #winid == 1 then
		winid = winid[1]
		-- do we have to use vim.api.nvim_tabpage_get_number(tabnr)?
		local tabnr = vim.api.nvim_win_get_tabpage(winid)
		local winnr = vim.api.nvim_win_get_number(winid)
		vim.cmd(tostring(tabnr) .. 'tabnext')
		vim.cmd(tostring(winnr) .. 'wincmd w')
	else -- if more or no window views are open for buffer
		vim.cmd(nvimtexis_vise_cmd .. ' ' .. file)
	end

	vim.cmd('normal!' .. tostring(line) .. 'G')
	vim.cmd('redraw')
end

return view
