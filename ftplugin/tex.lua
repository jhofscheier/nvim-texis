-- No 'exists(b:did_ftplugin)'. Load nvimtexis alongside other tex-plugins.
-- If vim.g.nvimtexis_enabled isn't set to 1 nothing will be imported.
if vim.g.nvimtexis_enabled then
	-- require nvimtexis to update server list (only once per neovim instance)
	require "nvimtexis"
end
