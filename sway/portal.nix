{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [slurp];
  xdg.portal = assert config.xdg.enable; {
    enable = true;
    config = {
      sway = {
        default = ["gtk"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
        "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };
}
