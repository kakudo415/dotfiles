#!/bin/bash -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET_COLOR='\033[0m'

exists() {
    type ${1} > /dev/null 2>&1
}

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
