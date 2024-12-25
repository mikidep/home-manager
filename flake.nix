{
  description = "Home Manager configuration of mikidep";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sway-new-workspace = {
      url = "github:mikidep/sway-new-workspace";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sway-workspace = {
      url = "github:matejc/sway-workspace";
      flake = false;
    };
    nix-env-fish = {
      url = "github:lilyball/nix-env.fish";
      flake = false;
    };
    BOSL2 = {
      url = "github:BelfrySCAD/BOSL2";
      flake = false;
    };
    lasercut-box-openscad = {
      url = "github:larsch/lasercut-box-openscad";
      flake = false;
    };
    swayws-src = {
      url = "github:mikidep/swayws";
      flake = false;
    };
    mikidep-neovim = {
      url = "github:mikidep/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agda-docsets = {
      url = "github:phijor/agda-docsets";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };
    fuse-archive-yazi = {
      url = "github:dawsers/fuse-archive.yazi";
      flake = false;
    };
    agda-cubical = {
      url = "github:agda/cubical";
      flake = false;
    };
    i3-switch-if-workspace-empty = {
      url = "github:giuseppe-dandrea/i3-switch-if-workspace-empty";
      flake = false;
    };
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in {
    homeConfigurations.mikidep = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      extraSpecialArgs = {
        inherit inputs;
        nur = inputs.nur.legacyPackages.${system};
      };

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = with inputs; [
        ./home.nix
        ./desktop.nix
        inputs.nix-index-database.hmModules.nix-index
        {
          nixpkgs.overlays = [
            (_: prev: {
              sway-new-workspace = sway-new-workspace.packages.${system}.default;
              swayws = let
                pkg = {
                  lib,
                  rustPlatform,
                }:
                  rustPlatform.buildRustPackage {
                    pname = "swayws";
                    version = "1.2.0-mikidep";
                    src = inputs.swayws-src;
                    cargoHash = "sha256-MXP/MDd/PXDFEeNwZOTxg0Ac1Z5NbY/Li7+7rvN8rB8=";

                    # swayws does not have any tests
                    doCheck = false;

                    meta = with lib; {
                      description = "Sway workspace tool which allows easy moving of workspaces to and from outputs";
                      mainProgram = "swayws";
                      homepage = "https://gitlab.com/mikidep/swayws";
                      license = licenses.mit;
                      maintainers = [maintainers.atila];
                    };
                  };
              in
                pkgs.callPackage pkg {};
            })
          ];
        }
      ];
    };
  };
}
