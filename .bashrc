# If not running interactively, don't do anything
# https://www.gnu.org/software/bash/manual/html_node/Is-this-Shell-Interactive_003f.html
case $- in
    *i*) ;;
      *) return;;
esac

# Options
shopt -s checkwinsize
shopt -s histappend

# Prompt
# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# /usr/share/bash-completion/completions/git
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM='auto'
PS1='
\[\e[32m\]\u@\H\[\e[0m\]: \[\e[36m\]\w
\[\e[33m\]$(__git_ps1 "(%s) ")\[\e[0m\]\$ '

# History
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
HISTSIZE=1000
HISTFILESIZE=10000
HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S %Z  '
HISTIGNORE='history:pwd:ls:ls *:la:la *'
HISTCONTROL=ignoreboth

# Aliases
# https://github.com/lsd-rs/lsd
[ -f ~/.cargo/env ] && . ~/.cargo/env
if type 'lsd' > /dev/null 2>&1
then
    alias ls='lsd'
fi
alias ll='ls -alF'
alias la='ls -A'
