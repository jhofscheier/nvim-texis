local M = {}

---@class NvimTeXis.Config
---@field cache? table<string,string>
---@field inverse_search? table
local defaults = {
	---@class Cache.Config
	---@field filename string
	cache = {
		---path and filename where nvim-rpc-servernames are stored
		filename = vim.api.nvim_call_function(
			'stdpath',
			{'cache'}
		) .. '/nvim_servernames.log',
	},
	---@class InverseSearch.Config
	---@field edit_cmd function()
	---@field pre_cmd? nil|function()
	---@field post_cmd? nil|function()
	inverse_search = {
		---command used for inverse search to open file (equivalent to `:e`)
		edit_cmd = vim.cmd.edit,
		---nil or function that is executed before inverse search is executed
		---@type nil|function()
		pre_cmd = nil,
		---nil or function that is exectued after inverse seach is executed
		---@type nil|function()
		post_cmd = nil,
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
