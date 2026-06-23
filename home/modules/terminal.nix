{
  # nixpkgs 26.05 marks ghostty as unsupported on aarch64-darwin.
  # Keep the config declarative without enabling the unavailable package.
  xdg.configFile."ghostty/config".text = ''
    font-family = Cica
    font-size = 16

    background-opacity = 0.85
    background-blur-radius = 15
  '';
}
