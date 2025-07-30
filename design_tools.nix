{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    openscad-unstable
    prusa-slicer
  ];

  home.file.BOSL2 = {
    source = "${inputs.BOSL2}";
    target = ".local/share/OpenSCAD/libraries/BOSL2";
  };
  home.file.lasercut-box-openscad = {
    source = "${inputs.lasercut-box-openscad}";
    target = ".local/share/OpenSCAD/libraries/lasercut-box-openscad";
  };
  # Originally published by user Anachronist on Printables:
  # https://www.printables.com/model/831732-fast-voronoi-method-for-openscad/
  home.file.fastvoronoi = {
    source = ./assets/fastvoronoi;
    target = ".local/share/OpenSCAD/libraries/fastvoronoi";
  };
}
