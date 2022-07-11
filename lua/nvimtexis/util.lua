-- utility functions used elsewhere

local util = {}

local cache = require('nvimtexis.cache')

-- only for local use here
-- checks if string `str` ends with `ending`
local function ends_with(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end

-- check if file has been loaded into buffer and return buffer handle
-- otherwise raise error
function util.bufid(file)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if ends_with(vim.api.nvim_buf_get_name(buf), file) then
			return buf
		end
	end
	error(file .. ' not loaded into a buffer')
end

-- check if buffer has a window and return window handle
-- otherwise raise error
function util.winid(buffer)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == buffer then
			return win
		end
	end
	error('No window for buffer ' .. buffer)
end

function util.open(file)
	if vim.api.nvim_call_function('filereadable', {file}) ~= 1 then
		error("Reverse goto failed; file not readable: '" .. file .. "'")
	end

	-- file is readable; open it
	local ok, _ = pcall(vim.cmd, cache.nvimtexis_vise_cmd .. ' ' .. file)
	if not ok then
		error("Reverse goto failed; command error: " ..
									cache.nvimtexis_vise_cmd .. " " .. file)
	end
	return vim.api.nvim_get_current_buf()
end

return util
