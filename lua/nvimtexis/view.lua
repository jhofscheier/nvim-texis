-- Functions for inverse search used by the neovim
-- instance that has loaded the tex-file.

local view = {}

local cache = require('nvimtexis.cache')
local util = require('nvimtexis.util')
local uv = vim.loop

function view.inverse_search(filename, line)
	-- resolve possible symlinks
	local file = uv.fs_realpath(filename)
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
	return true
end

return view
