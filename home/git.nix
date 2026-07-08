{ config, pkgs, ... }:

{
  xdg = {
    enable = true;

    configFile."git/git-completion.sh".source =
      "${pkgs.git}/share/git/contrib/completion/git-completion.bash";
    configFile."git/git-prompt.sh".source = "${pkgs.git}/share/git/contrib/completion/git-prompt.sh";
  };

  programs.git = {
    enable = true;
    package = pkgs.git;
    signing = {
      format = "openpgp";
      key = null;
      signByDefault = true;
    };
    ignores = [
      ".DS_Store"
      ".claude/settings.local.json"
    ];
    includes = [
      {
        path = "${config.xdg.configHome}/git/config.local";
      }
    ];
    settings = {
      user = {
        name = "KAKUDO Kentaro";
        email = "31888089+kakudo415@users.noreply.github.com";
      };
      core = {
        editor = "nvim";
      };
    };
  };
}
