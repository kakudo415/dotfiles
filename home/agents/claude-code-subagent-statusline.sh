# shellcheck shell=bash

jq --compact-output '
  def percent: "\(round)%";
  def dim: "\u001b[2m\(.)\u001b[22m";
  def joinNonEmpty(separator): map(select(length > 0)) | join(separator);
  def tokens: if . >= 1000000 then (. / 1000000 * 10 | round | . / 10 | tostring) + "M" elif . >= 1000 then (. / 1000 | round | tostring) + "K" else tostring end;

  .tasks[]
  | select(.contextWindowSize != null)
  | ("\([.tokenCount / .contextWindowSize * 100, 100] | min | percent) " + ("(\(.tokenCount | tokens)/\(.contextWindowSize | tokens))" | dim)) as $context
  | {
      id,
      content: ([.name // .agentType // "", .model // "", $context, (.label // "" | if length > 0 then "\"\(.)\"" else . end)] | joinNonEmpty(" │ "))
    }
'
