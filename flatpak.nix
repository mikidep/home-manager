{
  pkgs,
  lib,
  ...
}: {
  services.flatpak = {
    packages = [
      "flathub:app/org.telegram.desktop//stable"
      
    ];
  };
}
