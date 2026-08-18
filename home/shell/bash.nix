{ lib, ... }:

let
  shellCommon = import ./common.nix;
in
{
  programs.bash = {
    enable = true;
    enableCompletion = false;

    # The Nix installer writes this into /etc/bashrc, which macOS updates
    # overwrite. Sourcing it here keeps Nix on PATH without depending on a
    # system-owned file. bashrcExtra rather than initExtra, because /etc/bashrc
    # sources it before the interactive-shell guard.
    bashrcExtra = ''
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    '';

    shellOptions = [
      "checkwinsize"
      "histappend"
    ];

    historySize = 1000;
    historyFileSize = 10000;
    historyControl = [
      "ignoreboth"
    ];
    historyIgnore = [
      "history"
      "pwd"
      "ls"
      "ls *"
      "la"
      "la *"
    ];

    inherit (shellCommon) shellAliases;

    initExtra = lib.mkMerge [
      (lib.mkOrder 1000 ''
        # Prompt
        # https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
        . ~/.config/git/git-completion.sh
        . ~/.config/git/git-prompt.sh
        ${shellCommon.gitPromptEnvironment}

        if type __git_ps1 > /dev/null 2>&1; then
        PS1='
        \[\e[32m\]\u@\H\[\e[0m\]: \[\e[36m\]\w
        \[\e[33m\]$(__git_ps1 "(%s) ")\[\e[0m\]\$ '
        else
        PS1='
        \[\e[32m\]\u@\H\[\e[0m\]: \[\e[36m\]\w
        \[\e[0m\]\$ '
        fi

        # History
        PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
        HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S %Z  '
      '')

      (lib.mkOrder 1500 ''
        if [[ -r ~/.bashrc.local ]]; then
          . ~/.bashrc.local
        fi
      '')
    ];
  };
}
