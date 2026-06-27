{ pkgs, ... }:

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
    ignores = [
      ".DS_Store"
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
