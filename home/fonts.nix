{ pkgs, ... }:

let
  cica = pkgs.callPackage ../pkgs/cica.nix { };
in
{
  home = {
    packages = [
      cica
    ];

    file = builtins.listToAttrs (
      map (font: {
        name = "Library/Fonts/${font}";
        value.source = "${cica}/share/fonts/truetype/${font}";
      }) cica.passthru.fonts
    );
  };
}
