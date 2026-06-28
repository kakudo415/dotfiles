{
  shellAliases = {
    ls = "lsd";
    ll = "ls -alF";
    la = "ls -A";
  };

  gitPromptEnvironment = ''
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM='auto'
  '';
}
