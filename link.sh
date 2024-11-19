#!/bin/bash -eu

iso8601() {
    date -u '+%Y%m%dT%H%M%SZ'
}

dotlink() {
    if [ -f "$HOME/${1}" ] && [ ! -L "$HOME/${1}" ]; then
        echo -n '[Backup] '
        cp -v "$HOME/${1}" "$HOME/${1}-$(iso8601)"
    fi

    echo -n '[Link]   '
    mkdir -p "$HOME/$(dirname ${1})"
    ln -snfv "$(cd $(dirname ${0}); pwd)/${1}" "$HOME/${1}"
}

# git
dotlink .config/git/config
dotlink .config/git/ignore

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

# zsh
dotlink .zshrc
