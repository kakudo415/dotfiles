{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gdb
    gnupg
    jq
    lsd
  ];
}
