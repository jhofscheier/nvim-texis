local M = {}

---@class NvimTeXis.Config
---@field cache? table<string,string>
---@field inverse_search? table
local defaults = {
	---@class Cache.Config
	---@field filename string
	cache = {
		filename = vim.api.nvim_call_function('stdpath', {'cache'}) ..
													'/nvim_servernames.log',
	},
	---@class InverseSearch.Config
	---@field edit_cmd function()
	---@field pre_cmd? function()
	---@field post_cmd? function()
	inverse_search = {
		edit_cmd = vim.cmd.edit,
		pre_cmd = function ()
			return true
		end,
		post_cmd = function ()
			return true
		end,
	},
}

---@type NvimTeXis.Config
local options

---Overwrites plugin options with user settings.
---@param opts? NvimTeXis.Config
function M.setup(opts)
	opts = opts or {}
	options = vim.tbl_deep_extend("force", defaults, opts)
end

return setmetatable(M, {
	__index = function(_, key)
		if options == nil then
			return vim.deepcopy(defaults)[key]
		end
		return options[key]
	end,
})
