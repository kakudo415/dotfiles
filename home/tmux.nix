{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    customPaneNavigationAndResize = true;
    escapeTime = 0;
    historyLimit = 10000;
    keyMode = "vi";
    prefix = "C-j";
    resizeAmount = 5;

    extraConfig = ''
      set  -g renumber-windows on

      # Colours: (10) 15 > 7 > 8

      # Panes
      set -g pane-active-border-style fg=colour7
      set -g pane-border-style        fg=colour8

      # STATUS LINE
      set -g status-justify  absolute-centre
      set -g status-interval 1
      set -g status-style    fg=terminal,bg=terminal

      set -g status-left        " #H > #[fg=colour7]#[fg=colour10]#S#[fg=colour7] "
      set -g status-left-length 50

      setw -g window-status-current-format " #[fg=colour10]#I#[fg=colour8]:#[fg=colour15]#W "
      setw -g window-status-format         " #[fg=colour7]#I#[fg=colour8]:#[fg=colour7]#W "

      set -g status-right        " %Y-%m-%d %H:%M:%S #[fg=colour8]%Z "
      set -g status-right-length 30

      setw -g pane-border-status bottom # To display a border above the status line
      setw -g pane-border-format ""     # https://github.com/tmux/tmux/issues/795
    '';
  };
}
