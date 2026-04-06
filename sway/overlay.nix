{
  pkgs,
  lib,
  ...
}: {
  nixpkgs.overlays = [
    (_: prev: {
      swayws = let
        pkg = {
          lib,
          rustPlatform,
          fetchFromGitHub,
        }: let
          src = fetchFromGitHub {
            owner = "mikidep";
            repo = "swayws";
            rev = "cff04fa";
            hash = "sha256-oJuhQA8IJvzh6iw0l5B/cvj4Wi0+k/8hY8imiykDS0k=";
          };
        in
          rustPlatform.buildRustPackage {
            pname = "swayws";
            version = "1.2.0-mikidep";
            inherit src;
            cargoLock.lockFile = "${src}/Cargo.lock";

            # swayws does not have any tests
            doCheck = false;

            meta = with lib; {
              description = "Sway workspace tool which allows easy moving of workspaces to and from outputs";
              mainProgram = "swayws";
              homepage = "https://github.com/mikidep/swayws";
              license = licenses.mit;
              maintainers = [maintainers.atila];
            };
          };
      in
        pkgs.callPackage pkg {};
      sway-workspace = let
        src = pkgs.fetchFromGitHub {
          owner = "matejc";
          repo = "sway-workspace";
          rev = "d89d3e9";
          hash = "sha256-8rxO/jvLLRwU7LVX4UxA65+/1BI3rK5uJXkKIGbs5as=";
        };
      in
        pkgs.rustPlatform.buildRustPackage {
          name = "sway-workspace";
          inherit src;
          cargoLock.lockFile = "${src}/Cargo.lock";
        };
    })
  ];
}
