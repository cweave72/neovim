#!/bin/bash

VIMFILES=~/vimfiles
patch -u -b $VIMFILES/vimrc -i drmike_vimrc.patch
