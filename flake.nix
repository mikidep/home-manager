{
  description = "Home Manager configuration of mikidep";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
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
    swayws = {
      url = "github:mikidep/swayws";
      inputs.nixpkgs.follows = "nixpkgs";
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

      extraSpecialArgs = {inherit inputs;};

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = with inputs; [
        ./home.nix
        ./desktop.nix
        inputs.nix-index-database.hmModules.nix-index
        {
          nixpkgs.overlays = [
            (_: _: {
              sway-new-workspace = sway-new-workspace.packages.${system}.default;
              swayws = swayws.packages.${system}.default;
            })
          ];
        }
      ];
    };
  };
}
