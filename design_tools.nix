{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [openscad prusa-slicer];

  home.file.BOSL2 = {
    source = "${inputs.BOSL2}";
    target = ".local/share/OpenSCAD/libraries/BOSL2";
  };
  home.file.lasercut-box-openscad = {
    source = "${inputs.lasercut-box-openscad}";
    target = ".local/share/OpenSCAD/libraries/lasercut-box-openscad";
  };
}
