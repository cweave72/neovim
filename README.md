[//]: tocstart
Table of Contents
-----------------
* [Vim Configuration](#vim-configuration)
  * [How to set up Doc Mike's vimfiles](#how-to-set-up-doc-mike's-vimfiles)
  * [Building Vim from source (probably not necessary)](#building-vim-from-source-(probably-not-necessary))
  * [Neovim setup](#neovim-setup)
    * [Installing](#installing)
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

## How to set up Doc Mike's vimfiles

Clone Doc Mike's vimfiles repo:

    git clone https://github.com/drmikehenry/vimfiles

Set up symbolic link:

    cd ~
    ln -s /path/to/vimfiles .vim

In .bashrc, set the following variable:

    export VIMUSERLOCALFILES=~/linuxconfig/vimlocal

When you launch `vim`, you should be running Mike's config and the
vimrc-after.vim found in vimlocal/.

The file `vimrc-vars.vim` is where we add user configurations that need to be
done early in the initialization process. For example, this is where we can
disable plugins from being loaded.

## Building Vim from source (probably not necessary)

The script `vimlocal/build_vim_from_source.sh` will pull the version of vim
specified and builds.  When completed, `cd` into the downloaded directory and
run:

    sudo make install

This will install vim to the path specified by `BUILD_PREFIX` in the script (`/usr/local`).

Variables to change in the script:

    VERSION     : Specifies the branch of vim/vim.git to clone.
    PYTHON3_VER : Specifies the python3 interpreter to use when Vim uses python3

## Neovim setup

Neovim looks very interesting and seems to work just fine with Doc Mike's normal
vim configuration + my vimrc-after.vim.  Below are some notes about how to set
it up, specifically about handling nvim-only plugins.

### Installing

Download the desired Neovim AppImage (v0.9.1 at time of writing):

    https://github.com/neovim/neovim/releases/tag/v0.9.1

(I usually put AppImages in ~/AppImages/)
Then make it executable:

    chmod u+x nvim.appimage 

### Configuring for compatibility with Doc Mike's config

Neovim installation creates ~/.config/nvim.
Place the following in `~/.config/nvim/init.vim` to allow Doc Mike's vimrc to
run.

```vim
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
```

### Directory structure

Reference: `$VIMUSERLOCALFILES = ~/linuxconfig/vimlocal`

The following directory structure is used:

```
$VIMUSERLOCALFILES/
├── vimrc-vars.vim                # Enable/Disable bundle plugins (pathogen)
├── vimrc-after.vim               # User vimrc
├── plugins.vim                   # List of vim-plug plugins
├── lua                           # user lua modules
│   └── user                      # user namespace for lua inits
│       ├── init.lua              # user init for neovim
│       ├── lsp_config.lua        # user config for lsp's and completion
│       └── telescope             # user plugin-specific inits
│           ├── init.lua
│           └── mappings.lua
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
          |--> plugins.vim
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

Handling external plugins (outside of Doc Mike's provided list) is now handled
via the `vim-plug` plugin. This plugin is bootstrapped in the `plugins.vim`
file. The plug.vim is located locally and copied to where it needs to be based
on whether vim or nvim is runnning: 

```vim
" Bootstrap vim-plug, if necessary.
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
let plugvim = $VIMUSERLOCALFILES . '/plug.vim'
let autoload_dir = data_dir . '/autoload'
if empty(glob(data_dir . '/autoload/plug.vim'))
    echom "Copying " plugvim . " to " . autoload_dir
    silent execute '!cp ' . plugvim . ' ' . autoload_dir
endif
```

Where `plug.vim` is placed:

vim: `~/.vim/autoload/`

nvim: `~/.local/share/nvim/site/`

With plug.vim, plugins are downloaded directly from github:

```vim
" plugins.vim
let plugged = $VIMUSERLOCALFILES . '/plugged/'

call plug#begin(plugged)

" Vim or Nvim
Plug 'francoiscabrol/ranger.vim'
Plug 'vim-scripts/Align'

" Add neovim plugins.
if has('nvim')
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

    "Required by ranger.vim
    Plug 'rbgrouleff/bclose.vim'
endif

call plug#end()
```

Note: Unmanaged plugins may be added by providing a path to the plugin source,
for example:

```vim
Plug "~/linuxconfig/vimlocal/path/to/plugin/plugin.vim"
```

Neovim plugins (lua):

Plugin-specific lua configuration should be located in the `vimlocal/lua/user/`
directory. Nvim will look for lua files for loading in a `lua/` directory on the
runtimepath.

### Updating Plugins

Execute the following to manually run plug.vim:

1. Installing new plugins after modifying `plugins.vim`:  `:PlugInstall --sync`
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

