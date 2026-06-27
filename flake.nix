{
  description = "kakudo415 dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      homeConfigurations.kakudo = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home
        ];
      };
    };
}
