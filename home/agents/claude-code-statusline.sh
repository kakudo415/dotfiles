# shellcheck shell=bash

input="$(</dev/stdin)"

currentDir="$(jq --raw-output '.workspace.current_dir // .workspace.project_dir // empty' <<< "$input")"

branchName=""
remoteUrl=""
if [ -n "$currentDir" ]; then
  branchName="$(git -C "$currentDir" branch --show-current 2>/dev/null || true)"
  remoteUrl="$(git -C "$currentDir" remote get-url origin 2>/dev/null || true)"
fi

jq --raw-output \
  --arg branchName "$branchName" \
  --arg remoteUrl "$remoteUrl" '
  def percent: "\(round)%";
  def dim: "\u001b[2m\(.)\u001b[22m";
  def joinNonEmpty(separator): map(select(length > 0)) | join(separator);
  def tokens: if . >= 1000000 then (. / 1000000 * 10 | round | . / 10 | tostring) + "M" elif . >= 1000 then (. / 1000 | round | tostring) + "K" else tostring end;
  def resetInHoursMinutes: (. - now) as $remain | " (\($remain / 3600 | floor)h \(($remain % 3600) / 60 | floor)m)" | dim;
  def resetInDaysHours: (. - now) as $remain | " (\($remain / 86400 | floor)d \(($remain % 86400) / 3600 | floor)h)" | dim;
  def rateLimit(name; resetFormat): if .used_percentage == null or .resets_at == null then "" else "\(name) \(.used_percentage | percent)\(.resets_at | resetFormat)" end;
  def ownerRepo:
    sub("^[A-Za-z][A-Za-z0-9+.-]*://"; "")
    | sub("^[^/@]*@"; "")
    | sub("^[^/:]+(:[0-9]+)?[:/]"; "")
    | sub("/+$"; "")
    | sub("\\.git$"; "")
    | split("/")
    | .[-2:]
    | join("/");

  (.model.display_name // "") as $model
  | (.context_window | if .used_percentage == null then "" else "\(.used_percentage | percent) " + ("(\(.total_input_tokens | tokens)/\(.context_window_size | tokens))" | dim) end) as $context
  | (.rate_limits.five_hour | rateLimit("5h"; resetInHoursMinutes)) as $fiveHour
  | (.rate_limits.seven_day | rateLimit("7d"; resetInDaysHours)) as $sevenDay
  | ($remoteUrl | ownerRepo) as $ownerRepo
  | (if .workspace.git_worktree == null then "" else "(\(.workspace.git_worktree))" | dim end) as $worktree

  | [
      ([$model, $context, $fiveHour, $sevenDay] | joinNonEmpty(" │ ")),
      ([([$ownerRepo, $branchName] | joinNonEmpty(" │ ")), $worktree] | joinNonEmpty(" "))
    ]
  | joinNonEmpty("\n")
' <<< "$input"
