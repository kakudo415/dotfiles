{ pkgs, ... }:

let
  jsonFormat = pkgs.formats.json { };

  claudeCodeSettings = {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";
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
    effortLevel = "xhigh";
    language = "japanese";
    theme = "dark";
    tui = "fullscreen";
    permissions = {
      allow = [
        "Bash(git add *)"
        "Bash(git commit *)"
        "Bash(git fetch *)"
        "Bash(git clone *)"
        "Bash(git checkout *)"
        "Bash(git switch *)"
        "Bash(git merge *)"
        "Bash(git stash *)"
        "Bash(git worktree *)"
        "Bash(go *)"
        "Bash(gofmt *)"
        "Bash(goimports *)"
        "Bash(golangci-lint *)"
        "Bash(staticcheck *)"
        "Bash(gh auth status *)"
        "Bash(gh status *)"
        "Bash(gh repo view *)"
        "Bash(gh issue list *)"
        "Bash(gh issue status *)"
        "Bash(gh issue view *)"
        "Bash(gh pr list *)"
        "Bash(gh pr status *)"
        "Bash(gh pr view *)"
        "Bash(gh pr diff *)"
        "Bash(gh pr checks *)"
        "Bash(gh run list *)"
        "Bash(gh run view *)"
        "Bash(gh workflow list *)"
        "Bash(gh workflow view *)"
        "Bash(gh release list *)"
        "Bash(gh release view *)"
      ];
    };
  };

  claudeCodePackage = pkgs.writeShellScriptBin "claude" ''
    exec "${pkgs.llm-agents.claude-code}/bin/claude" --settings "$HOME/.claude/settings.shared.json" "$@"
  '';
in
{
  programs.claude-code = {
    enable = true;
    package = claudeCodePackage;
    context = ./PROMPT.md;
  };

  home.file.".claude/settings.shared.json".source =
    jsonFormat.generate "claude-code-settings.shared.json" claudeCodeSettings;
}
