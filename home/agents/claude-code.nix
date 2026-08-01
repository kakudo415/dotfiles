{ pkgs, ... }:

let
  jsonFormat = pkgs.formats.json { };

  statusLineScript = pkgs.writeShellScript "claude-code-statusline" ''
    input="$(cat)"

    firstLine="$(printf '%s' "$input" | ${pkgs.jq}/bin/jq --raw-output '
      def percent: "\(round)%";
      def dim: "\u001b[2m\(.)\u001b[22m";
      def formatTokens: if . >= 1000000 then (. / 1000000 * 10 | round | . / 10 | tostring) + "M" elif . >= 1000 then (. / 1000 | round | tostring) + "K" else tostring end;
      def resetInHoursMinutes: (. - now) as $remain | ($remain / 3600 | floor) as $hours | (($remain % 3600) / 60 | floor) as $minutes | " (\($hours)h \($minutes)m)" | dim;
      def resetInDaysHours: (. - now) as $remain | ($remain / 86400 | floor) as $days | (($remain % 86400) / 3600 | floor) as $hours | " (\($days)d \($hours)h)" | dim;
      def rateLimit(name; resetFormat): select(.used_percentage != null) | "\(name) \(.used_percentage | percent)\(.resets_at | resetFormat)";
      [
        (.model.display_name // empty),
        (.context_window | select(.used_percentage != null) | "\(.used_percentage | percent) " + ("(\(.total_input_tokens | formatTokens)/\(.context_window_size | formatTokens))" | dim)),
        (.rate_limits.five_hour | rateLimit("5h"; resetInHoursMinutes)),
        (.rate_limits.seven_day | rateLimit("7d"; resetInDaysHours))
      ] | join(" │ ")
    ')"

    currentDir="$(printf '%s' "$input" | ${pkgs.jq}/bin/jq --raw-output '.workspace.current_dir // .workspace.project_dir // empty')"
    branchName=""
    if [ -n "$currentDir" ]; then
      branchName="$(${pkgs.git}/bin/git -C "$currentDir" branch --show-current 2>/dev/null)"
    fi

    secondLine="$(printf '%s' "$input" | ${pkgs.jq}/bin/jq --raw-output --arg branchName "$branchName" '
      def dim: "\u001b[2m\(.)\u001b[22m";
      if .workspace.repo.name == null then empty else
        (if .workspace.repo.owner == null then .workspace.repo.name else "\(.workspace.repo.owner)/\(.workspace.repo.name)" end) as $ownerRepo |
        (.workspace.git_worktree // "") as $worktree |
        (if $worktree == "" then "" else (" (\($worktree))" | dim) end) as $worktreeSuffix |
        [
          $ownerRepo,
          ($branchName | select(length > 0) | . + $worktreeSuffix)
        ] | join(" │ ")
      end
    ')"

    if [ -n "$secondLine" ]; then
      printf '%s\n%s\n' "$firstLine" "$secondLine"
    else
      printf '%s\n' "$firstLine"
    fi
  '';

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
    statusLine = {
      type = "command";
      command = "${statusLineScript}";
    };
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
