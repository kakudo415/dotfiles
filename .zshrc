# Options
setopt PROMPT_SUBST

# Prompt
# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
. ~/.config/git/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM='auto'
PS1=$'
%{\e[32m%}%n@%m%{\e[0m%}: %{\e[36m%}%~
%{\e[33m%}$(__git_ps1 "(%s) ")%{\e[0m%}\$ '

# Aliases
# https://github.com/lsd-rs/lsd
[ -f ~/.cargo/env ] && . ~/.cargo/env
if type 'lsd' > /dev/null 2>&1
then
    alias ls='lsd'
fi
alias ll='ls -alF'
alias la='ls -A'
