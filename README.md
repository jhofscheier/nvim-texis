# nvim-texis
This [Neovim](https://neovim.io) plugin provides inverse search functionality for TeX-PDF synchronisation. It is inspired by VimTeX's inverse search implementation (see [VimTeX pull request #2219](https://github.com/lervag/vimtex/pull/2219))

# Requirements
nvim-texis requires Neovim version 0.4.3, a working LaTeX installation with synctex, and a PDF viewer supporting synctex (for example, [Evince](https://wiki.gnome.org/Apps/Evince), [Okular](https://okular.kde.org/), [Skim](https://sourceforge.net/p/skim-app/wiki/TeX_and_PDF_Synchronization), [SumatraPDF](https://www.sumatrapdfreader.org/free-pdf-reader.html), or [Zathura](https://pwmt.org/projects/zathura/)).

# Installation
Using [vim-plug](https://github.com/junegunn/vim-plug)
```vimscript
Plug 'jhofscheier/nvim-texis'
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use 'jhofscheier/nvim-texis'
```
Enable the plugin by setting `nvimtexis_enabled` to true. For example, in `init.vim` add
```vimscript
let g:nvimtexis_enabled = v:true
```
Alternatively, add the following line to your `init.lua`
```lua
vim.g.nvimtexis_enabled = true
```

# Configuration

Compile LaTeX documents with synctex enabled (for example, by using the `-synctex` or `--synctex` flag).

Configure your PDF viewer to communicate with Neovim. This step will depend on the chosen viewer. You need a viewer that has an option called something like "inverse search command-line" where you can specify a shell command to perform the inverse search. The target file and line are usually provided via interpolation variables, say `%file` for the file and `%line` for the line. A typical shell command looks like this:
```shell
nvim --headless -c "set filetype=nvimtexis" -c "NvimTeXInverseSearch %line, '%file'"
```
For example, for [Skim](https://sourceforge.net/p/skim-app/wiki/TeX_and_PDF_Synchronization/#tex-pdf-synchronization) go to the Sync preferences, choose the 'Custom' preset, use `nvim` for 'Command' and `--headless -c "set filetype=nvimtexis" -c "NvimTeXInverseSearch %line, '%file'"` as 'Arguments. Now you can perform an inverse search by Shift-Command-click on a point in a PDF document. 