{ config, lib, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = false;

    setOptions = [
      "PROMPT_SUBST"
    ];

    shellAliases = {
      ls = "lsd";
      ll = "ls -alF";
      la = "ls -A";
    };

    initContent = lib.mkOrder 1000 ''
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
    '';
  };
}
