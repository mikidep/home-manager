{
  pkgs,
  lib,
  ...
}: {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.mainBar = {
      position = "bottom";
      layer = "top";
      modules-left = ["hyprland/workspaces" "hyprland/submap"];
      modules-center = ["hyprland/window"];
      modules-right = ["memory" "network" "disk" "wireplumber" "battery" "clock"];
      "hyprland/window" = {
        max-length = 50;
      };
      battery = {
        format = "{capacity}% {icon} ";
        format-icons = ["" "" "" "" ""];
      };
      clock = {
        format = "{:%a, %d. %b  %H:%M}";
      };
      network = {
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ipaddr}/{cidr}  ";
      };
      disk = {
        path = "/";
        format = "DU {percentage_used}%";
      };
      wireplumber = {
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        scroll-step = 5;
        format = "{node_name} {volume}% {icon}";
        format-muted = "";
      };
      memory = {
        format = "RAM {percentage}%";
        interval = 5;
      };
    };
  };
  programs.rofi = {
    enable = true;
    theme = "solarized";
    modes = [
      "run"
      "drun"
      "combi"
      "calc"
      {
        name = "pm";
        path = lib.getExe pkgs.rofi-power-menu;
      }
    ];
    plugins = [
      pkgs.rofi-calc
    ];
  };
}
