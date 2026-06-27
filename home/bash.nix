{
  programs.bash = {
    enable = true;
    enableCompletion = false;

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

    shellAliases = {
      ls = "lsd";
      ll = "ls -alF";
      la = "ls -A";
    };

    initExtra = ''
      # Prompt
      # https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
      . ~/.config/git/git-completion.sh
      . ~/.config/git/git-prompt.sh
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

      # History
      PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
      HISTTIMEFORMAT='%Y-%m-%d %H:%M:%S %Z  '
    '';
  };
}
