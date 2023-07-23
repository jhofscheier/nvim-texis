# nvim-texis
This [Neovim](https://neovim.io) plugin provides inverse search functionality for TeX-PDF synchronisation.
It is inspired by VimTeX's inverse search implementation (see [VimTeX pull request #2219](https://github.com/lervag/vimtex/pull/2219)).

## Table of Contents
1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [nvim-lspconfig Configuration Guide](#nvim-lspconfig-configuration-guide)
5. [Usage](#usage)
6. [Improving Inverse Search Performance](#improving-inverse-search-performance)

## Requirements
- [Neovim](https://github.com/neovim/neovim) 0.8+
- Working LaTeX installation with synctex (for example, [TeX Live](https://tug.org/texlive/))
- PDF viewer supporting synctex (for example, [Evince](https://wiki.gnome.org/Apps/Evince), [Okular](https://okular.kde.org/), [sioyek](https://github.com/ahrm/sioyek), [Skim](https://sourceforge.net/p/skim-app/wiki/TeX_and_PDF_Synchronization), [SumatraPDF](https://www.sumatrapdfreader.org/free-pdf-reader.html), or [Zathura](https://pwmt.org/projects/zathura/)).
- [TexLab](https://github.com/latex-lsp/texlab)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

## Installation
Install the plugin with your preferred package manager:

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'jhofscheier/nvim-texis'
```

Then run `require("nvimtexis").setup({ your options })` at an appropriate place in your config code.
Refer to the [Configuration](#configuration) Section below for further details about available options.

### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "jhofscheier/nvim-texis",
    dependencies = { "neovim/nvim-lspconfig", },
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
},
```

## Configuration

**nvim-texis.nvim** is configured using the `setup` function.
This function accepts an optional argument: a table containing your settings.
Please refer to the default settings below.

```lua
{
    "jhofscheier/nvim-texis",
    dependencies = { "neovim/nvim-lspconfig", },
    opts = {
        cache = {
            ---path and filename where nvim-rpc-servernames are stored
            filename = vim.api.nvim_call_function(
                'stdpath',
                {'cache'}
            ) .. '/nvim_servernames.log',
        },
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
    },
},
```

The `inverse_search.pre_cmd` and `inverse_search.post_cmd` hooks can be used to customise the inverse search feature.
For instance, if you use the [kitty](https://github.com/kovidgoyal/kitty) terminal, you can implement a `post_cmd` hook that refocuses on the terminal each time an inverse search is executed.
This provides an efficient and smooth editing experience.

```lua
post_cmd = function ()
        vim.fn.system([[osascript -e 'activate application "kitty"']])
    end
```

This `post_cmd` hook is intentionally simplistic and works optimally when a single instance of the kitty terminal is open.
However, if your workflow involves multiple kitty OS windows or tabs within kitty, you may require a more sophisticated `post_cmd` hook.

## nvim-lspconfig Configuration Guide

**nvim-texis** is designed to support inverse search, but not forward search.
This plugin is optimised to work synergistically with the [TexLab](https://github.com/latex-lsp/texlab) LSP server and [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig).
To assist you with setting up forward search using [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig), we have provided a sample configuration below:

```lua
{
    "neovim/nvim-lspconfig",
    dependencies = {
        -- your dependencies
    },
    config = function ()
        local lsp = require("lspconfig")
        -- your other nvim-lsp config code

        lsp.texlab.setup({
            filetypes = { 'tex', 'bib', 'plaintex' },
            on_attach = -- your on_attach function
            log_level = vim.lsp.protocol.MessageType.Log,
            message_level = vim.lsp.protocol.MessageType.Log,
            flags = {
                debounce_text_changes = 150,
            },
            settings = {
                texlab = {
                    -- if you want to use chktex
                    chktex = { onOpenAndSave = true },
                    formaterLineLength = 80,
                    forwardSearch = {
                        executable = "sioyek",
                        args = {
                            "--forward-search-file",
                            "%f",
                            "--forward-search-line",
                            "%l",
                            "%p",
                        },
                    },
                    -- configuration suggestion for Skim
                    -- forwardSearch = {
                    --     executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
                    --     args = {"-g", "%l", "%p", "%f"},
                    -- },
                },
            },
            capabilities = -- your capabilities
        })
    end,
}
```

## Usage

Compile LaTeX documents with synctex enabled (for example, by using the `-synctex` or `--synctex` flag).

You will need to configure your PDF viewer to communicate with Neovim.
This step will depend on the chosen viewer.
Ensure your viewer includes an option akin to “inverse search command-line”.
This allows you to set a shell command to execute the inverse search.

The target file and line number are typically specified using interpolation variables.
For instance, `%file` would represent the file, while `%line` would denote the line number.
A typical shell command looks like this:
```bash
nvim --headless -c "NvimTeXInverseSearch '%file' %line"
```

### Skim
For [Skim](https://sourceforge.net/p/skim-app/wiki/TeX_and_PDF_Synchronization/#tex-pdf-synchronization) go to the Sync preferences, choose the 'Custom' preset, use `nvim` for 'Command' and `--headless -c "NvimTeXInverseSearch '%file' %line"` as arguments.
Now you can perform an inverse search by Shift-Command-click on a point in a PDF document. 

### sioyek
For [sioyek](https://github.com/ahrm/sioyek) you will need to modify the `prefs_user` settings.
Run the `:prefs_user` command and add the following lines to your configuration:

```bash
# The command to use when trying to do inverse search into a LaTeX document. Uncomment and provide your own command.
# %1 expands to the name of the file and %2 expans to the line number.
inverse_search_command 		nvim --headless -c "NvimTeXInverseSearch '%1' %2"
```
## Improving Inverse Search Performance
Inverse search can consume a non-trivial amount of time for loading a “headless instance” of Neovim, particularly if you have numerous plugins installed.
To expedite this process, consider using the following optimised inverse search command in your PDF viewer:

```bash
nvim -u NONE -i NONE --headless -c "set rtp+=[plugins path]/nvim-texis" -c "source [plugins path]/nvim-texis/plugin/nvimtexis.lua" -c "NvimTeXInverseSearch '%file' %line"
```
In the command above, replace `[plugins path]` with the directory path where your plugins are located.

This command performs several operations:
* `-u NONE` instructs Neovim not to load any user configuration files and plugins.
* `-i NONE` prevents Neovim from loading the shada file.
* `-c "set rtp+=[plugins path]/nvim-texis"` and `-c "source [plugins path]/nvim-texis/plugin/nvimtexis.lua"` are used to manually load the nvim-texis plugin.

For example, if you are using [lazy.nvim](https://github.com/folke/lazy.nvim) and [sioyek](https://github.com/ahrm/sioyek), the command would typically look like this:

```bash
nvim -u NONE -i NONE --headless -c "set rtp+=~/.local/share/nvim/lazy/nvim-texis" -c "source ~/.local/share/nvim/lazy/nvim-texis/plugin/nvimtexis.lua" -c "NvimTeXInverseSearch '%1' %2"
```
