-- Functions for inverse search used by the neovim
-- instance that has loaded the tex-file.

local view = {}

local Config = require("nvimtexis.config")
local util = require('nvimtexis.util')
local uv = vim.loop

---Opens the file `filename` and jumps to given line number `line`.
---@param filename string
---@param line integer
---@return boolean
function view.inverse_search(filename, line)
	---@type nil|function()
	local pre_cmd = Config.inverse_search.pre_cmd
	if pre_cmd ~= nil then
		pre_cmd()
	end

	-- resolve possible symlinks
	---@type string
	local file = uv.fs_realpath(filename)
	---@type integer, integer, integer, boolean
	local buf, win, tab, ok

	-- is file already loaded into a buffer?
	ok, buf = pcall(util.bufid, file)
	if not ok then
		-- open file if necessary
		ok, buf = pcall(util.open, file)
		if not ok then
			return false
		end
	end

	-- line within range?
	if (line > vim.api.nvim_buf_line_count(buf)) or (line < 1) then
		return false
	end

	-- default to `normal mode`
	if vim.api.nvim_get_mode()['mode'] == 'i' then
		vim.cmd('stopinsert')
	end

	-- get buffer, window, and tab handles
	ok, win = pcall(util.winid, buf)
	if ok then
		tab = vim.api.nvim_win_get_tabpage(win)
		-- If tab/window exists, switch to it/them
		vim.api.nvim_set_current_tabpage(tab)
		vim.api.nvim_set_current_win(win)
	else -- if no window for buffer use current window
		vim.api.nvim_set_current_buf(buf)
		win = 0 -- use current window
	end

	vim.api.nvim_win_set_cursor(win, { line, 0 })

	---@type nil|function()
	local post_cmd = Config.inverse_search.post_cmd
	if post_cmd ~= nil then
		post_cmd()
	end

	return true
end

return view
