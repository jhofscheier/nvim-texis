local cache = require("nvimtexis.cache")
local Config = require("nvimtexis.config")

local M = {}

---Sets the plugin up by overwriting default settings with user's configuration
---and creates autocommands for cache management.
---@param user_opts NvimTeXis.Config?
function M.setup(user_opts)
	Config.setup(user_opts)
	cache.autocmd_servernames()
end

return M
