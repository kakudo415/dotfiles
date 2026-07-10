{ pkgs, ... }:

{
  imports = [
    ./agents
    ./fonts.nix
    ./gpg.nix
    ./git.nix
    ./ghostty.nix
    ./editors
    ./shell
    ./tmux.nix
  ];

  home = {
    username = "kakudo";
    homeDirectory = "/Users/kakudo";
    stateVersion = "26.05";
    enableNixpkgsReleaseCheck = false;

    packages = with pkgs; [
      ghostty-bin
      go
      lsd
      orbstack
      pinentry_mac
    ];
  };

  programs.home-manager.enable = true;
}
