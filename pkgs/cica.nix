{
  fetchzip,
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "cica";
  version = "5.0.3";

  src = fetchzip {
    url = "https://github.com/miiton/Cica/releases/download/v${version}/Cica_v${version}.zip";
    hash = "sha256-BtDnfWCfD9NE8tcWSmk8ciiInsspNPTPmAdGzpg62SM=";
    stripRoot = false;
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 Cica-Regular.ttf "$out/share/fonts/truetype/Cica-Regular.ttf"
    install -Dm644 Cica-RegularItalic.ttf "$out/share/fonts/truetype/Cica-RegularItalic.ttf"
    install -Dm644 Cica-Bold.ttf "$out/share/fonts/truetype/Cica-Bold.ttf"
    install -Dm644 Cica-BoldItalic.ttf "$out/share/fonts/truetype/Cica-BoldItalic.ttf"
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
