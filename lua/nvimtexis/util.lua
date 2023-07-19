-- utility functions used elsewhere

local Config = require("nvimtexis.config")
local uv = vim.loop

local util = {}

---check if file has been loaded into buffer and return buffer handle otherwise
---raise error
---@param file string
---@return integer
function util.bufid(file)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.endswith(vim.api.nvim_buf_get_name(buf), file) then
			return buf
		end
	end
	error(file .. ' not loaded into a buffer')
end

---check if buffer has a window and return window handle otherwise raise error
---@param buffer integer
---@return integer
function util.winid(buffer)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == buffer then
			return win
		end
	end
	error('No window for buffer ' .. buffer)
end

---Returns true if `file` is readable; returns false otherwise
---@param file string Path to file
---@return boolean
function util.file_readable(file)
	local fd = uv.fs_open(file, "r", 438) -- 438 corresponds to octal 0666
    if fd ~= nil then
    	fd:close()
		return true
    end
	return false
end

---Opens `file` and returns the buffer number of the corresponding buffer.
---@param file string
---@return integer
function util.open(file)
	if not util.file_readable(file) then
		error("Reverse goto failed; file not readable: '" .. file .. "'")
	end

	-- file is readable; open it
	---@type boolean
	local ok, _ = pcall(Config.inverse_search.edit_cmd, file)
	if not ok then
		error("Reverse goto failed; command error: " ..
					vim.inspect(Config.inverse_search.edit_cmd) .. " " .. file)
	end
	return vim.api.nvim_get_current_buf()
end

return util
