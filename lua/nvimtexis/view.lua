-- Functions for inverse search used by the neovim
-- instance that has loaded the tex-file.

local view = {}

local cache = require('nvimtexis.cache')

local function ends_with(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

local function is_buffer_loaded(file)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if ends_with(vim.api.nvim_buf_get_name(buf), file) then
			return buf
		end
	end
	return -1
end

local function winid_of_buffer(buffer)
	for _, winid in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(winid) == buffer then
			return winid
		end
	end
	return -1
end

function view.inverse_search(line, file_name)
	-- resolve possible symlinks
	local file = vim.api.nvim_call_function('resolve', {file_name})
	if vim.api.nvim_get_mode()['mode'] == 'i' then
		vim.cmd('stopinsert')
	end

	local bufnr = is_buffer_loaded(file)
	if buf == -1 then
		if vim.api.nvim_call_function('filereadable', {file}) == 1 then
			local status_ok, _ = pcall(vim.cmd,
									   cache.nvimtexis_vise_cmd .. ' ' .. file)
			if not status_ok then
				print("Reverse goto failed; command error: ",
					  cache.nvimtexis_vise_cmd, file)
				return -3
			end
			bufnr = vim.api.nvim_get_current_buf()
		else
			print("Reverse goto failed; file not readable: '", file, "'")
			return -4
		end
	end

	-- Get buffer, window, and tab numbers
	-- * If tab/window exists, switch to it/them
	local winid = winid_of_buffer(bufnr)
	if winid >= 0 then
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
