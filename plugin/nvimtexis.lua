if vim.g.loaded_nvimtexis == 1 then
	return
end
vim.g.loaded_nvimtexis = 1

local caller = require('nvimtexis.caller')

vim.api.nvim_create_user_command('NvimTeXInverseSearch', function(args_tbl)
		caller.inverse_search(args_tbl.args)
	end,
	{
		nargs = '+',
	}
)
