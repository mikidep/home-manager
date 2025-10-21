{
  pkgs,
  mynur,
  ...
}: {
  home.packages = with pkgs; [
    prusa-slicer
    (mynur.openscadWithPackages (with mynur.openscadPackages; [
      BOSL2
      mikidep-scad
      nopscadlib
    ]))
  ];
}
