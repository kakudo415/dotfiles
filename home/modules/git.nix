{ config, ... }:

{
  programs.git = {
    enable = true;
    ignores = [ ".DS_Store" ];
    includes = [
      {
        path = "${config.xdg.configHome}/local/git/config";
      }
    ];
    settings = {
      user = {
        name = "KAKUDO Kentaro";
        email = "31888089+kakudo415@users.noreply.github.com";
      };
      core.editor = "nvim";
    };
  };
}
