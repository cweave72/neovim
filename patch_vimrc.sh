#!/bin/bash
#
# After updating to Neovim v0.9.1, there are some minor patches needed to allow
# Doc Mike's config to run properly with Neovim.

VIMFILES=~/vimfiles
patch -u -b $VIMFILES/vimrc -i drmike_vimrc.patch
