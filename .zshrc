# Options
setopt PROMPT_SUBST

# Prompt
# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
. ~/.config/git/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM='auto'

if type __git_ps1 > /dev/null 2>&1; then
PS1=$'
%{\e[32m%}%n@%m%{\e[0m%}: %{\e[36m%}%~
%{\e[33m%}$(__git_ps1 "(%s) ")%{\e[0m%}\$ '
else
PS1=$'
%{\e[32m%}%n@%m%{\e[0m%}: %{\e[36m%}%~
%{\e[0m%}\$ '
fi

# Aliases
# https://github.com/lsd-rs/lsd
[ -f ~/.cargo/env ] && . ~/.cargo/env
if type 'lsd' > /dev/null 2>&1
then
    alias ls='lsd'
fi
alias ll='ls -alF'
alias la='ls -A'

# Environment variables
export LLVM16="/Users/kakudo/Documents/github.com/kakudo415/llvm-project/build/bin"
export PATH="/Users/kakudo/bin/sass_embedded:$PATH"

export DENO_INSTALL="/Users/kakudo/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/textlive/2023/bin/universal-darwin:$PATH"

export PATH="/Users/kakudo/Downloads/jdk-22.0.1.jdk/Contents/Home/bin:$PATH"
export PATH="/Users/kakudo/bin:$PATH"

# opam configuration
[[ ! -r /Users/kakudo/.opam/opam-init/init.zsh ]] || source /Users/kakudo/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

[ -f "/Users/kakudo/.ghcup/env" ] && . "/Users/kakudo/.ghcup/env" # ghcup-env
