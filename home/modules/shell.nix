{ pkgs, ... }:

let
  gitPrompt = "${pkgs.git}/share/git/contrib/completion/git-prompt.sh";
  gitCompletion = "${pkgs.git}/share/bash-completion/completions/git";
in
{
  programs.bash = {
    enable = true;
    shellOptions = [
      "checkwinsize"
      "histappend"
    ];
    historySize = 1000;
    historyFileSize = 10000;
    historyIgnore = [
      "history"
      "pwd"
      "ls"
      "ls *"
      "la"
      "la *"
    ];
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
    };
    initExtra = ''
      # Prompt
      . ${gitCompletion}
      . ${gitPrompt}
      GIT_PS1_SHOWDIRTYSTATE=1
      GIT_PS1_SHOWSTASHSTATE=1
      GIT_PS1_SHOWUNTRACKEDFILES=1
      GIT_PS1_SHOWUPSTREAM='auto'

      if type __git_ps1 > /dev/null 2>&1; then
      PS1='
      \[\e[32m\]\u@\H\[\e[0m\]: \[\e[36m\]\w
      \[\e[33m\]$(__git_ps1 "(%s) ")\[\e[0m\]\$ '
      else
      PS1='
      \[\e[32m\]\u@\H\[\e[0m\]: \[\e[36m\]\w
      \[\e[0m\]\$ '
      fi

      HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S %Z  '
      PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

      # https://github.com/lsd-rs/lsd
      [ -f ~/.cargo/env ] && . ~/.cargo/env
      if type 'lsd' > /dev/null 2>&1
      then
          alias ls='lsd'
      fi

      local_bashrc="''${XDG_CONFIG_HOME:-$HOME/.config}/local/shell/bashrc"
      [ -r "$local_bashrc" ] && . "$local_bashrc"
    '';
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
    };
    initContent = ''
      # Options
      setopt PROMPT_SUBST

      # Prompt
      . ${gitPrompt}
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

      # https://github.com/lsd-rs/lsd
      [ -f ~/.cargo/env ] && . ~/.cargo/env
      if type 'lsd' > /dev/null 2>&1
      then
          alias ls='lsd'
      fi

      local_zshrc="''${XDG_CONFIG_HOME:-$HOME/.config}/local/shell/zshrc"
      [ -r "$local_zshrc" ] && . "$local_zshrc"
    '';
  };
}
