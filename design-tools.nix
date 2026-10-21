{
  pkgs,
  mynur,
  ...
}: {
  home.packages = with pkgs; let
    openscad = mynur.openscadWithPackages (with mynur.openscadPackages; [
      BOSL2
      mikidep-scad
      nopscadlib
    ]);
  in [
    prusa-slicer
    (
      pkgs.writeShellApplication {
        name = "openscad";
        runtimeInputs = [openscad];
        text = ''nvidia-offload openscad "$@"'';
      }
    )
    kicad-unstable
  ];
}
