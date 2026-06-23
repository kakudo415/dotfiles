{ config, lib, ... }:

{
  imports = [
    ./modules/json-merge.nix
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/tmux.nix
    ./modules/neovim.nix
    ./modules/terminal.nix
    ./modules/gdb.nix
    ./modules/claude.nix
    ./modules/tools.nix
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
  xdg.enable = true;

  home.activation.initLocalLayer = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    local_config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
    local_root="$local_config_home/local"

    mkdir -p \
      "$local_root/shell" \
      "$local_root/git" \
      "$local_root/claude"

    touch "$local_root/shell/bashrc"
    touch "$local_root/shell/zshrc"
    touch "$local_root/git/config"

    if [ ! -e "$local_root/claude/settings.json" ]; then
      printf '{}\n' > "$local_root/claude/settings.json"
    fi

    if [ ! -e "$local_root/README.local.md" ]; then
      cat > "$local_root/README.local.md" <<'EOF'
# Local dotfiles layer

This directory is intentionally outside Git. Put machine-specific and secret
settings here.

- shell/bashrc
- shell/zshrc
- git/config
- claude/settings.json
EOF
    fi
  '';
}
