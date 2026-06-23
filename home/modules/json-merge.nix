{ config, lib, pkgs, ... }:

let
  cfg = config.local.jsonMerge;

  mergeType = lib.types.submodule (
    { ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "Name used for the activation DAG entry.";
        };
        commonFile = lib.mkOption {
          type = lib.types.path;
          description = "Common JSON file generated in the Nix store.";
        };
        localFile = lib.mkOption {
          type = lib.types.str;
          description = "Runtime local JSON file path.";
        };
        targetFile = lib.mkOption {
          type = lib.types.str;
          description = "Runtime merged JSON target path.";
        };
      };
    }
  );

  mergeCommands = lib.concatMapStringsSep "\n" (
    merge:
    ''
      local_json="${merge.localFile}"
      target_json="${merge.targetFile}"
      mkdir -p "$(dirname "$local_json")" "$(dirname "$target_json")"

      if [ ! -e "$local_json" ]; then
        printf '{}\n' > "$local_json"
      fi

      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' '${merge.commonFile}' "$local_json" > "$target_json.tmp"
      mv "$target_json.tmp" "$target_json"
    ''
  ) cfg.files;
in
{
  options.local.jsonMerge.files = lib.mkOption {
    type = lib.types.listOf mergeType;
    default = [ ];
    description = "JSON files to merge during Home Manager activation.";
  };

  config = lib.mkIf (cfg.files != [ ]) {
    home.activation.mergeLocalJson = lib.hm.dag.entryAfter [ "initLocalLayer" ] mergeCommands;
  };
}
