{pkgs, ...}: {
  home.packages = with pkgs; [openscad freecad prusa-slicer];

  home.file.BOSL2 = {
    source = let
      src = pkgs.fetchFromGitHub {
        owner = "BelfrySCAD";
        repo = "BOSL2";
        rev = "46f7835";
        hash = "sha256-rsQZM55OZw9hEX972+nrq9QU+Cc1S5oE/A3jIu4PFMg=";
      };
    in "${src}";
    target = ".local/share/OpenSCAD/libraries/BOSL2";
  };
  home.file.lasercut-box-openscad = {
    source = let
      src = pkgs.fetchFromGitHub {
        owner = "larsch";
        repo = "lasercut-box-openscad";
        rev = "0496a3a";
        hash = "sha256-L7cOuIUElCttGGPYZadp/1A986HlzMoBHKj1xk6B+vI=";
      };
    in "${src}";
    target = ".local/share/OpenSCAD/libraries/lasercut-box-openscad";
  };
}
