{ pkgs, ... }:

let
  cica = pkgs.callPackage ../pkgs/cica.nix { };
in
{
  home = {
    packages = [
      cica
    ];

    file = {
      "Library/Fonts/Cica-Bold.ttf".source = "${cica}/share/fonts/truetype/Cica-Bold.ttf";
      "Library/Fonts/Cica-BoldItalic.ttf".source = "${cica}/share/fonts/truetype/Cica-BoldItalic.ttf";
      "Library/Fonts/Cica-Regular.ttf".source = "${cica}/share/fonts/truetype/Cica-Regular.ttf";
      "Library/Fonts/Cica-RegularItalic.ttf".source =
        "${cica}/share/fonts/truetype/Cica-RegularItalic.ttf";
    };
  };
}
