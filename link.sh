#!/bin/bash -eu

DOTDEFAULT=$(cd $(dirname $0)/default/; pwd)

link() {
    mkdir -p ~/$(dirname ${1})
    ln -snfv ${DOTDEFAULT}/${1} ~/${1}
}

# git
link .config/git/config

# nvim
link .config/nvim/init.vim

