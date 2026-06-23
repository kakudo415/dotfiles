{ config, pkgs, ... }:

let
  commonSettings = pkgs.writeText "claude-settings-common.json" (
    builtins.toJSON {
      env = {
        EDITOR = "nvim";
        DISABLE_ERROR_REPORTING = 1;
        DISABLE_TELEMETRY = 1;
      };
      includeCoAuthoredBy = false;
    }
  );
in
{
  local.jsonMerge.files = [
    {
      name = "claude-settings";
      commonFile = commonSettings;
      localFile = "\${XDG_CONFIG_HOME:-$HOME/.config}/local/claude/settings.json";
      targetFile = "${config.home.homeDirectory}/.claude/settings.json";
    }
  ];
}
