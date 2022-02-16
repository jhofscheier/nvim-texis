-- Only load plugin if enabled
if not vim.g.nvimtexis_enabled then
	return
end

local cache = require "nvimtexis.cache"

-- Initialise cache.servernames
cache.init_servernames()
-- prune servernames and save to file
cache.prune_servernames()

