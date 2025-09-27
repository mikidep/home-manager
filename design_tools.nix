{
  pkgs,
  mynur,
  ...
}: {
  home.packages = with pkgs; [
    orca-slicer
    (mynur.openscadWithPackages (with mynur.openscadPackages; [
      BOSL2
      mikidep-scad
      nopscadlib
    ]))
  ];
}
