{ pkgs, ... }:

{
  imports = [
    ./agents
    ./bash.nix
    ./fonts.nix
    ./gpg.nix
    ./git.nix
    ./ghostty.nix
    ./neovim.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home = {
    username = "kakudo";
    homeDirectory = "/Users/kakudo";
    stateVersion = "26.05";
    enableNixpkgsReleaseCheck = false;

    packages = with pkgs; [
      ghostty-bin
      lsd
      pinentry_mac
    ];
  };

  programs.home-manager.enable = true;
}
