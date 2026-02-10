{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = lib.mkBefore ''
      @import url("file://${pkgs.waybar}/etc/xdg/waybar/style.css");

      .modules-right > widget > * {
          padding: 0 10px;
      }
    '';
    settings.mainBar = {
      position = "bottom";
      layer = "top";
      # modules-left = ["hyprland/workspaces" "hyprland/submap"];
      # modules-center = ["hyprland/window"];
      modules-left = ["sway/workspaces" "sway/mode"];
      modules-center = ["sway/window"];
      modules-right = ["memory" "network" "disk" "wireplumber" "battery" "clock" "custom/notification"];
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
      "custom/notification" = assert config.services.swaync.enable; {
        tooltip = false;
        format = "{} {icon}";
        "format-icons" = {
          notification = "󱅫";
          none = "";
          "dnd-notification" = " ";
          "dnd-none" = "󰂛";
          "inhibited-notification" = " ";
          "inhibited-none" = "";
          "dnd-inhibited-notification" = " ";
          "dnd-inhibited-none" = " ";
        };
        "return-type" = "json";
        exec = "swaync-client -swb";
        "on-click" = "sleep 0.1 && swaync-client -t -sw";
        "on-click-right" = "sleep 0.1 && swaync-client -d -sw";
        escape = true;
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
      {
        name = "bib";
        path = let
          libpath = "/home/mikidep/Documents/JabRef";
          rofi-bib = pkgs.writeShellScript "rofi-bib" ''
            if [ $# -eq 1 ]; then
              coproc (xdg-open "${libpath}/$1")
              exit 0
            else
              ls -1 --quoting-style literal ${libpath} | grep '\.pdf$'
            fi
          '';
        in "${rofi-bib}";
      }
    ];
    plugins = [
      pkgs.rofi-calc
    ];
  };
  home.packages = with pkgs; [
    (writeShellApplication {
      name = "rofi-menu";
      text = ''rofi -show combi -combi-modes "pm,drun,bib,window" -show-icons'';
    })
  ];
  services.swaync = {
    enable = true;
  };
}
