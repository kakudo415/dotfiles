#!/bin/bash -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET_COLOR='\033[0m'

exists() {
    type ${1} > /dev/null 2>&1
}

# Git completion and prompt

mkdir -p ~/.config/git/
[ ! -f ~/.config/git/git-completion.sh ] && curl -o ~/.config/git/git-completion.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
[ ! -f ~/.config/git/git-prompt.sh ] && curl -o ~/.config/git/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

# Install with Cargo

cargo_install() {
    if exists ${1}
    then
        echo -e "info: ${1} is already installed. Skipping..."
    else
        echo -e "info: Installing ${1}..."
        cargo install ${1}
    fi
}

if exists 'cargo'
then
    cargo_install 'bat'
    cargo_install 'lsd'
    cargo_install 'tokei'
else
    echo -e "${RED}error${RESET_COLOR}: Cargo is not installed."
fi

[ -f ~/.bashrc ] && . ~/.bashrc

echo -e "${GREEN}info${RESET_COLOR}: Installation complete."
