{
  description = "Home Manager configuration of mikidep";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-24.11";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
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
    agda-index = {
      url = "github:phijor/agda-index";
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
    i3-switch-if-workspace-empty = {
      url = "github:giuseppe-dandrea/i3-switch-if-workspace-empty";
      flake = false;
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    nixpkgs-stable,
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
    pkgs-stable = import nixpkgs-stable {
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
        inherit system;
        inherit pkgs-stable;
        nur = inputs.nur.legacyPackages.${system};
      };

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [
        ./home.nix
        ./desktop.nix
        (inputs.nix-index-database.hmModules.nix-index)
      ];
    };
  };
}
