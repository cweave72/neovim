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

Doc Mike's configuration is considered the base configuration which we are
extending.  Neovim-specific plugins are provided in his `vimfiles/nvim/bundle`
directory. To use these plugins and add any other plugins which are not
provided as standard in his config, the `plugins_after.vim` file is sourced in
my vimrc-after.vim script.

Neovim plugins (lua):

Plugin-specific lua configuration should be located in the `vimlocal/lua/user/`
directory. Nvim will look for lua files for loading in a `lua/` directory on the
runtimepath.

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

