{ lib, pkgs, ... }:

let
  statusLineScript = pkgs.writeShellApplication {
    name = "claude-code-statusline";
    runtimeInputs = [
      pkgs.git
      pkgs.jq
    ];
    text = builtins.readFile ./claude-code-statusline.sh;
  };

  subagentStatusLineScript = pkgs.writeShellApplication {
    name = "claude-code-subagent-statusline";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ./claude-code-subagent-statusline.sh;
  };

  claudeCodeSettings = {
    cleanupPeriodDays = 1825; # 5 years
    attribution = {
      commit = "";
      pr = "";
      sessionUrl = false;
    };
    includeGitInstructions = false;
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
    language = "japanese";
    statusLine = {
      type = "command";
      command = lib.getExe statusLineScript;
    };
    subagentStatusLine = {
      type = "command";
      command = lib.getExe subagentStatusLineScript;
    };
    outputStyle = "Concise";
    tui = "fullscreen";
    idleCompaction = false;
    theme = "dark";
  };

  claudeCodeStatelessPackage = pkgs.writeShellScriptBin "claude-stateless" ''
    export CLAUDE_CODE_SKIP_PROMPT_HISTORY=1
    export CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
    exec claude "$@"
  '';
in
{
  programs.claude-code = {
    enable = true;
    package = null;
    mutableSettings = true;
    settings = claudeCodeSettings;
    context = ./PROMPT.md;
    skills.delegate = ./skills/delegate/SKILL.md;
  };

  home = {
    packages = [ claudeCodeStatelessPackage ];

    sessionVariables = {
      DISABLE_ERROR_REPORTING = 1;
    };
  };
}
