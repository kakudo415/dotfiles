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
      go_latest
      (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
      (lib.hiPrio kubectl)
      lsd
      orbstack
      pinentry_mac
    ];
  };

  programs.home-manager.enable = true;
}
