{
  description = "kakudo415 dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      treefmt-nix,
      ...
    }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "orbstack"
          ];
      };
      treefmtEval = treefmt-nix.lib.evalModule pkgs {
        projectRootFile = "flake.nix";
        programs.nixfmt = {
          enable = true;
          package = pkgs.nixfmt;
        };
      };
    in
    {
      formatter.${system} = treefmtEval.config.build.wrapper;

      checks.${system} = {
        format = treefmtEval.config.build.check self;

        statix = pkgs.runCommand "statix-check" { nativeBuildInputs = [ pkgs.statix ]; } ''
          cd ${self}
          statix check .
          touch $out
        '';

        deadnix = pkgs.runCommand "deadnix-check" { nativeBuildInputs = [ pkgs.deadnix ]; } ''
          cd ${self}
          deadnix --fail .
          touch $out
        '';
      };

      homeConfigurations.kakudo = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home
        ];
      };
    };
}
