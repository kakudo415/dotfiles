{
  description = "kakudo415 dotfiles managed by Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."kakudo" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          {
            home.username = builtins.getEnv "USER";
            home.homeDirectory = builtins.getEnv "HOME";

            assertions = [
              {
                assertion = builtins.getEnv "USER" != "" && builtins.getEnv "HOME" != "";
                message = "USER and HOME must be available. Run Home Manager commands with --impure.";
              }
            ];
          }
          ./home
        ];
      };

      apps.${system}.home-manager = {
        type = "app";
        program = "${home-manager.packages.${system}.home-manager}/bin/home-manager";
      };

      checks.${system}.home = self.homeConfigurations."kakudo".activationPackage;
    };
}
