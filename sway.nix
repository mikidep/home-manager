{
  inputs,
  pkgs,
  lib,
  config,
  bg,
  ...
}: let
  update-lid =
    pkgs.writeShellScript
    "update-lid"
    ''
      if grep -q open /proc/acpi/button/lid/LID/state; then
          swaymsg output eDP-1 enable
      else
          swaymsg output eDP-1 disable
      fi
    '';
in {
  home.packages = with pkgs; [
    swaybg
    swaynotificationcenter
    sway-contrib.grimshot
  ];
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.mainBar = {
      position = "bottom";
      layer = "top";
      modules-left = ["sway/workspaces" "sway/mode"];
      modules-center = ["sway/window"];
      modules-right = ["memory" "network" "disk" "wireplumber" "battery" "clock"];
      "sway/window" = {
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
        on-click = "${pkgs.qpwgraph}/bin/qpwgraph";
        format = "{node_name} {volume}% {icon}";
        format-muted = "";
      };
      memory = {
        format = "RAM {percentage}%";
        interval = 5;
      };
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
      indicator-idle-visible = true;
    };
  };

  services.swayidle = let
    swaylock = "${pkgs.swaylock}/bin/swaylock";
  in {
    enable = false;
    events = [
      {
        event = "before-sleep";
        command = "${swaylock}";
      }
    ];
  };

  programs.swayr = {
    enable = true;
    systemd.enable = true;
  };
  wayland.windowManager.sway = let
    rofi = "${pkgs.rofi-wayland}/bin/rofi";
    rofi-pm = ''${pkgs.rofi-power-menu}/bin/rofi-power-menu'';
    rofi-menu = ''${rofi} -show combi -combi-modes "pm:${rofi-pm},window,drun" -show-icons -theme solarized'';
    rofi-run = ''${rofi} -show run -theme solarized'';
    terminal = "${pkgs.kitty}/bin/kitty";
    # currently, there is some friction between sway and gtk:
    # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
    # the suggested way to set gtk settings is with gsettings
    # for gsettings to work, we need to tell it where the schemas are
    # using the XDG_DATA_DIR environment variable
    # run at the end of sway config
    configure-gtk =
      pkgs.writeShellScript
      "configure-gtk"
      (
        let
          schema = pkgs.gsettings-desktop-schemas;
          datadir = "${schema}/share/gsettings-schemas/${schema.name}";
        in ''
          export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
          gnome_schema=org.gnome.desktop.interface
          gsettings set $gnome_schema gtk-theme 'Dracula'
        ''
      );
  in {
    enable = true;
    package = let
      cfg = config.wayland.windowManager.sway;
    in
      pkgs.sway.override {
        extraSessionCommands = cfg.extraSessionCommands;
        extraOptions = cfg.extraOptions;
        withBaseWrapper = cfg.wrapperFeatures.base;
        withGtkWrapper = cfg.wrapperFeatures.gtk;
      };
    systemd.enable = true;

    config = {
      input."*" = {
        xkb_layout = "us(altgr-intl)";
        xkb_numlock = "enabled";
        tap = "enabled";
        tap_button_map = "lrm";
      };

      keybindings =
        (
          let
            sway-workspace = let
              repo = inputs.sway-workspace;
              pkg = pkgs.rustPlatform.buildRustPackage {
                name = "sway-workspace";
                src = repo;
                cargoHash = "sha256-8gT/2RUDIOnmTznjlzupIapHjz2pNQjj3DZ0dg8f+VM=";
              };
            in "${pkg}/bin/sway-workspace";
            swayws = "${pkgs.swayws}/bin/swayws";
            movements = {
              left,
              right,
              up,
              down,
            }: {
              "Mod4+${left}" = "focus prev";
              "Mod4+${right}" = "focus next";
              "Mod4+${up}" = "focus parent";
              "Mod4+${down}" = "focus child";
              "Mod4+Shift+${left}" = "move left";
              "Mod4+Shift+${right}" = "move right";
              "Mod4+Shift+${up}" = "move up";
              "Mod4+Shift+${down}" = "move down";
              "Ctrl+Alt+${left}" = "workspace prev_on_output";
              "Ctrl+Alt+${right}" = "workspace next_on_output";
              "Ctrl+Alt+${up}" = "exec ${sway-workspace} prev-output";
              "Ctrl+Alt+${down}" = "exec ${sway-workspace} next-output";
              "Ctrl+Alt+Shift+${left}" = "move container to workspace prev_on_output, workspace prev_on_output;";
              "Ctrl+Alt+Shift+${right}" = "move container to workspace next_on_output, workspace next_on_output;";
              "Ctrl+Alt+Shift+${up}" = "exec ${sway-workspace} --move prev-output";
              "Ctrl+Alt+Shift+${down}" = "exec ${sway-workspace} --move next-output";
              "Ctrl+Mod4+Shift+${left}" = "exec ${swayws} swap current prev";
              "Ctrl+Mod4+Shift+${right}" = "exec ${swayws} swap current next";
            };
          in
            (movements {
              left = "H";
              right = "L";
              down = "J";
              up = "K";
            })
            // (movements {
              left = "Left";
              right = "Right";
              down = "Down";
              up = "Up";
            })
        )
        // (
          let
            sway-nw = "${pkgs.sway-new-workspace}/bin/sway-new-workspace";
            unmute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0";
            grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
          in {
            "Ctrl+Alt+N" = "exec ${sway-nw} open";
            "Ctrl+Alt+Shift+N" = "exec ${sway-nw} move";
            "Alt+F2" = "exec ${rofi-run}";
            "Mod4+space" = "exec ${rofi-menu}";
            "Mod4+V" = "layout toggle all";
            "Shift+Mod4+Q" = "kill";
            "Mod4+Return" = "exec ${terminal}";
            "Mod4+R" = "mode resize";

            "Print" = "exec ${grimshot} copy anything";
            "Shift+Print" = "exec ${grimshot} copy output";
            "XF86AudioRaiseVolume" = "exec ${unmute}; exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume" = "exec ${unmute}; exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
            "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s +10%";
            "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 10%-";
            "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          }
        );
      modes.resize = {
        "Escape" = "mode default";
        "L" = "resize grow width 10 px";
        "H" = "resize shrink width 10 px";
      };
      colors = {
        #   focused = {
        #     border = "#FF0000";
        #     background = "#285577";
        #     text = "#ffffff";
        #     indicator = "#2e9ef4";
        #     childBorder = "#0000FF";
        #   };
      };
      output = {
        "*" = {
          bg = "${bg} center #000000";
        };
        "Dell Inc. DELL P2719HC H5F9QS2" = {
          scale = "1";
        };
        "Dell Inc. DELL S2721D DTNDP43" = {
          scale = "1.25";
        };
        "LG Electronics LG HDR 4K 0x0007B5E8" = {
          scale = "2";
        };
      };

      window.titlebar = false;
      window.commands = [
        {
          command = "layout tabbed";
          criteria.app_id = "org.pwmt.zathura";
        }
      ];
      menu = rofi-menu;
      modifier = "Mod4";

      bars = [];

      gaps = {
        inner = 3;
        smartGaps = true;
        smartBorders = "on";
      };

      focus = {
        followMouse = false;
        newWindow = "urgent";
      };
    };

    extraConfig = let
      launch = "${pkgs.xdg-launch}/bin/xdg-launch";
    in ''
      exec ${configure-gtk}
      exec_always ${update-lid}

      bindswitch lid:on  exec ${update-lid}
      bindswitch lid:off exec ${update-lid}

      workspace number 1
      exec firefox
      workspace number 2
      exec ${terminal}
      workspace number 20
      exec telegram-desktop
      exec ${launch} whatsapp
    '';
  };
}
