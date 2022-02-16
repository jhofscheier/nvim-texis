" Code for inverse search with external pdf-viewer

if exists('g:loaded_nvimtexis') | finish | endif
let g:loaded_nvimtexis = 1

command! -nargs=* NvimTeXInverseSearch
	\ lua require('nvimtexis.caller').inverse_search(<args>)
