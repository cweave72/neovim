[//]: tocstart
Table of Contents
-----------------
* [Vim Configuration](#vim-configuration)
  * [How to set up Doc Mike's vimfiles as the baseline config](#how-to-set-up-doc-mike's-vimfiles-as-the-baseline-config)
    * [Configuring for compatibility with Doc Mike's config](#configuring-for-compatibility-with-doc-mike's-config)
    * [Directory structure](#directory-structure)
    * [Initialization with Neovim](#initialization-with-neovim)
    * [Plugins](#plugins)
    * [Updating Plugins](#updating-plugins)
    * [Pin Plugin to a tag or branch](#pin-plugin-to-a-tag-or-branch)
    * [LSP Setup](#lsp-setup)
      * [General](#general)
      * [Lua](#lua)
      * [Python](#python)
      * [Completions](#completions)
  * [Tips](#tips)
    * [Querying options and variables](#querying-options-and-variables)
    * [Load output of a command into a buffer](#load-output-of-a-command-into-a-buffer)
    * [Determine Python version](#determine-python-version)
    * [Insert output of vim command into text (see also :InsertCmd custom)](#insert-output-of-vim-command-into-text-(see-also-:insertcmd-custom))

[//]: tocend

# Vim Configuration

## How to set up Doc Mike's vimfiles as the baseline config

This Neovim configuration is based on using Doc Mike's repo as the base config.

Clone Doc Mike's vimfiles repo:

    git clone https://github.com/drmikehenry/vimfiles

Set up symbolic link to point to `vimfiles`:

    cd ~
    ln -s /path/to/vimfiles .vim

In .bashrc, set the following variable:

    export VIMUSERLOCALFILES=path/to/vimlocal

When you launch `vim`, you should be running Mike's config and the
vimrc-after.vim found in vimlocal/.

The file `vimrc-vars.vim` is where we add user configurations that need to be
done early in the initialization process. For example, this is where we can
disable plugins from being loaded.

### Configuring for compatibility with Doc Mike's config

Neovim installation creates ~/.config/nvim.
Place the following in `~/.config/nvim/init.vim` to allow Doc Mike's vimrc to
run.

```vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
```

Set the user .vimrc:
```bash
echo "runtime vimrc" > .vimrc
```

### Directory structure

The following general directory structure is used:

```
$VIMUSERLOCALFILES/
├── vimrc-vars.vim                # Enable/Disable bundle plugins (pathogen)
├── vimrc-after.vim               # User vimrc
├── plugins_after.vim             # Installs plugins extended from base
├── lua                           # User Lua moduled/inits
│   └── user
│       ├── cscope_maps           # Custom inits for plugins
│       ├── nvim-tree
│       ├── telescope
│       ├── init.lua              # User top-level init
│       ├── lsp_config.lua        # Configure LSPs and completion.
│       ├── mappings.lua          # User mappings
│       └── utils.lua             # User utils
├── plugged                       # output dir for vim-plug
│   ├── plugin
│   ├── ...
│   ├── plugin
├── UltiSnips
│   └── custom snippets
```

### Initialization with Neovim

Initialization order:

```
~/.vim/vimrc
 |--> $VIMUSERLOCALFILES/vimrc-vars.vim
     |--> $VIMUSERLOCALFILES/vimrc-after.vim
          |--> plugins_after.vim
          |
          ... (vim initialization completes)
          |
          |--> (autocmd VimEnter *) NvimStartup()
               |--> PlugInstall (if necessary)
               |--> user/init.lua
                    |--> user/lsp_config.lua
                    |--> user/telescope/init.lua
                    |--> ... (other inits)
```

### Plugins

`github.com/drmikehenry/vimfiles` is considered the base configuration which we
are extending.  Any plugins not provided in the base config are managed with the
`vim-plug` plugin and managed through the `plugins_after.vim` script.  Installed
plugins are stored locally in the `plugged/` directory. 

Several common Neovim-specific plugins are provided in the base config under the
`vimfiles/nvim/bundle` directory. To add any other plugins which are not
provided as standard in his config, the `plugins_after.vim` file is sourced from
the vimrc-after.vim script.

> Note:
> The plugins specified in `vimfiles/nvim/bundle` must be included in the
> `plugins_after.vim` script so that they are added to the runtimepath and
> properly loaded (i.e. their `<name>/plugin/<name>.lua` script must be
> sourced).  See example below on how to add base plugins for use. Once a plugin
> has been registered with vim-plug, custom configurations may be made.

```vim
" Path to Doc Mike's NVIM-specific bundles.
let nvim_bundle = $HOME . '/.vim/nvim/bundle/'

call plug#begin(plugged)
...
"Add bundled plugins provided by base config:
Plug nvim_bundle . 'cmp'
Plug nvim_bundle . 'cmp-buffer'
Plug nvim_bundle . 'cmp-cmdline'
Plug nvim_bundle . 'cmp-nvim-lsp'
Plug nvim_bundle . 'cmp-nvim-ultisnips'
Plug nvim_bundle . 'cmp-path'
Plug nvim_bundle . 'lspconfig'
Plug nvim_bundle . 'null-ls'
Plug nvim_bundle . 'plenary'
Plug nvim_bundle . 'telescope'
Plug nvim_bundle . 'which-key'

call plug#end()
```

After running nvim after a fresh checkout, run :PlugInstall to gather any
plugins specified in `plugins_after.vim`.

Neovim plugins (lua):

Plugin-specific lua configurations should be located under the
`vimlocal/lua/user/` directory. Nvim will look for lua files for loading in a
`user/lua/` directory on the runtimepath.

### Updating Plugins

Execute the following to manually run plug.vim:

1. Installing new plugins after modifying `plugins_after.vim`:  `:PlugInstall --sync`
2. Updating plugins: `:PlugUpdate`

### Pin Plugin to a tag or branch

Example:

```vim
Plug 'nvim-tree/nvim-tree.lua' { 'tag': 'compat-nvim-0.7' }
**or**
Plug 'nvim-tree/nvim-tree.lua' { 'branch': '<name of branch>' }
```

### LSP Setup

#### General

See [`lua/user/lsp_config.lua`](lua/user/lsp_config.lua)

#### Lua

Getting and building the lua language server, Sumneko:

```bash
git clone https://github.com/sumneko/lua-language-server
cd lua-language-server/
git submodule update --init --recursive
```

Building:
(Note: I needed to install libstdc++-static for the build to complete)

```bash
cd 3rd/luamake
compile/install.sh
cd ../..
./3rd/luamake/luamake rebuild
```

#### Python

Using nvim-lsp pylsp.

Install language servers:
```bash
python3 -m pip install python-language-server[all]
```

#### Completions

Currently using `'hrsh7th/nvim-cmp'` completion plugin.

## Tips

### Querying options and variables

Options (things like `set numberwidth`:

    :set optionname?              # current value
    :verbose set optionname?      # current value + who set it last

Globals

    :echo g:variable_name

### Load output of a command into a buffer

Example: Search through list of loaded plugins  (custom cmd :ShowLoadedPlugins)

    :enew
    :pu=execute('scriptnames')

### Determine Python version

    :py3 import sys; print(sys.executable)

### Insert output of vim command into text (see also :InsertCmd custom)

    :put=execute('command')        # see :help put

