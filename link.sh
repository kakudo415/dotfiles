#!/bin/bash -eu

dotlink() {
    mkdir -p ~/$(dirname ${1})
    ln -snfv $(cd $(dirname ${0}); pwd)/${1} ~/${1}
}

# git
dotlink .config/git/config

# nvim
dotlink .config/nvim/init.vim

# tmux
dotlink .config/tmux/tmux.conf

# gdb
dotlink .config/gdb/gdbinit

# sura (https://github.com/kakudo415/sura)
dotlink .config/sura/config.json

# bash
dotlink .bashrc

