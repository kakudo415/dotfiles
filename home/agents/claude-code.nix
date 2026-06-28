{ pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    package = pkgs.llm-agents.claude-code;
    context = ./PROMPT.md;
    settings = {
      env = {
        EDITOR = "nvim";
        DISABLE_AUTOUPDATER = 1;
        DISABLE_ERROR_REPORTING = 1;
        DISABLE_TELEMETRY = 1;
      };
      attribution = {
        commit = "";
        pr = "";
        sessionUrl = false;
      };
      language = "japanese";
      permissions = {
        allow = [
          "Bash(pwd)"
          "Bash(ls:*)"
          "Bash(git status:*)"
          "Bash(git diff:*)"
          "Bash(git log:*)"
          "Bash(git show:*)"
          "Bash(git branch:*)"
          "Bash(git commit:*)"
          "Bash(gh auth status:*)"
          "Bash(gh status:*)"
          "Bash(gh repo view:*)"
          "Bash(gh issue list:*)"
          "Bash(gh issue status:*)"
          "Bash(gh issue view:*)"
          "Bash(gh pr list:*)"
          "Bash(gh pr status:*)"
          "Bash(gh pr view:*)"
          "Bash(gh pr diff:*)"
          "Bash(gh pr checks:*)"
          "Bash(gh run list:*)"
          "Bash(gh run view:*)"
          "Bash(gh workflow list:*)"
          "Bash(gh workflow view:*)"
          "Bash(gh release list:*)"
          "Bash(gh release view:*)"
        ];
      };
    };
  };
}
