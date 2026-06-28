{
  fetchzip,
  lib,
  stdenvNoCC,
}:

let
  cicaFonts = [
    "Cica-Regular.ttf"
    "Cica-RegularItalic.ttf"
    "Cica-Bold.ttf"
    "Cica-BoldItalic.ttf"
  ];
in
stdenvNoCC.mkDerivation rec {
  pname = "cica";
  version = "5.0.3";

  src = fetchzip {
    url = "https://github.com/miiton/Cica/releases/download/v${version}/Cica_v${version}.zip";
    hash = "sha256-BtDnfWCfD9NE8tcWSmk8ciiInsspNPTPmAdGzpg62SM=";
    stripRoot = false;
  };

  dontBuild = true;

  passthru.fonts = cicaFonts;

  installPhase = ''
    runHook preInstall

    ${lib.concatMapStringsSep "\n    " (
      font: ''install -Dm644 ${font} "$out/share/fonts/truetype/${font}"''
    ) cicaFonts}
    install -Dm644 LICENSE.txt "$out/share/doc/${pname}/LICENSE.txt"
    install -Dm644 COPYRIGHT.txt "$out/share/doc/${pname}/COPYRIGHT.txt"

    runHook postInstall
  '';

  meta = {
    description = "Japanese monospace programming font";
    homepage = "https://github.com/miiton/Cica";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
