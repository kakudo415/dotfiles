{ config, lib, ... }:

let
  shellCommon = import ./common.nix;
in
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = false;

    setOptions = [
      "PROMPT_SUBST"
    ];

    inherit (shellCommon) shellAliases;

    initContent = lib.mkOrder 1000 ''
      # Prompt
      # https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
      . ~/.config/git/git-prompt.sh
      ${shellCommon.gitPromptEnvironment}

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
