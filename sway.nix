{
  pkgs,
  lib,
  config,
  bg,
  ...
}: {
  home.packages = with pkgs; [swaybg swaynotificationcenter];
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.mainBar = {
      position = "bottom";
      layer = "top";
      modules-left = ["sway/workspaces" "sway/mode"];
      modules-center = ["sway/window"];
      modules-right = ["network" "disk" "wireplumber" "battery" "clock"];
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
        format = "Disk usage: {percentage_used}%";
      };
      wireplumber = {
        on-click = "${pkgs.qpwgraph}/bin/qpwgraph";
        format = "{node_name} {volume}% {icon}";
        format-muted = "";
      };
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
    };
  };

  services.swayidle = let
    swaylock = "${pkgs.swaylock}/bin/swaylock";
  in {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${swaylock}";
      }
    ];
    timeouts = [
      {
        timeout = 300;
        command = let
          suslock = pkgs.writeShellApplication {
            name = "suslock";
            runtimeInputs = with pkgs; [swaylock systemd];

            text = ''
              if not pgrep -l swaylock
              then swaylock -fF
              fi

              systemctl suspend
            '';
          };
        in "${suslock}";
      }
    ];
  };

  wayland.windowManager.sway = let
    rofi = "${pkgs.rofi-wayland}/bin/rofi";
    rofi-pm = ''${pkgs.rofi-power-menu}/bin/rofi-power-menu'';
    rofi-menu = ''${rofi} -show combi -combi-modes "pm:${rofi-pm},window,drun" -show-icons -theme solarized'';
    rofi-run = ''${rofi} -show run -theme solarized'';
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
    update-lid =
      pkgs.writeShellScript
      "update-lid"
      ''
        #!/bin/sh
        if grep -q open /proc/acpi/button/lid/LID/state; then
            swaymsg output eDP-1 enable
        else
            swaymsg output eDP-1 disable
        fi
      '';
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

    config = {...}: {
      config = {
        input."*" = {
          xkb_layout = "it";
          xkb_numlock = "enabled";
          tap = "enabled";
          tap_button_map = "lrm";
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
          "LG Electronics LG HDR 4K 0x0000B7E8" = {
            scale = "2";
          };
        };

        window.titlebar = false;
        terminal = "kitty";
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
      options.keybindings = lib.mkOption {
        # This is quite cursed. See https://github.com/NixOS/nixpkgs/issues/16884
        apply = defaultKb:
          defaultKb
          // lib.attrsets.mapAttrs'
          (k: v: {
            name = "Ctrl+Alt+${k}";
            value = v;
          })
          (
            let
              sway-nw = "${pkgs.sway-new-workspace}/bin/sway-new-workspace";
              sway-workspace = let
                repo = pkgs.fetchFromGitHub {
                  owner = "matejc";
                  repo = "sway-workspace";
                  rev = "0ca7c7d";
                  hash = "sha256-4Jyyve9HqiSzE+WGooKnzXjnIG+6HZIolf0P7fo47HU=";
                };
                pkg = pkgs.rustPlatform.buildRustPackage {
                  name = "sway-workspace";
                  src = repo;
                  cargoSha256 = "sha256-DRUd2nSdfgiIiCrBUiF6UTPYb6i8POQGo1xU5CdXuUY=";
                };
              in "${pkg}/bin/sway-workspace";
              movements = {
                left,
                right,
                up,
                down,
              }: {
                "${left}" = "workspace prev_on_output";
                "${right}" = "workspace next_on_output";
                "${up}" = "exec ${sway-workspace} prev-output";
                "${down}" = "exec ${sway-workspace} next-output";
                "Shift+${left}" = "move container to workspace prev_on_output, workspace prev_on_output;";
                "Shift+${right}" = "move container to workspace next_on_output, workspace next_on_output;";
                "Shift+${up}" = "exec ${sway-workspace} --move prev-output";
                "Shift+${down}" = "exec ${sway-workspace} --move next-output";
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
              // {
                "N" = "exec ${sway-nw} open";
                "Shift+N" = "exec ${sway-nw} move";
              }
          )
          // (
            let
              unmute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0";
            in {
              "Alt+F2" = "exec ${rofi-run}";
              "Mod4+space" = "exec ${rofi-menu}";

              "XF86AudioRaiseVolume" = "exec ${unmute}; exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
              "XF86AudioLowerVolume" = "exec ${unmute}; exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
              "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s +10%";
              "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl s 10%-";
              "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            }
          );
      };
    };

    extraConfig = let
      launch = "${pkgs.xdg-launch}/bin/xdg-launch";
    in ''
      exec ${configure-gtk}
      exec_always ${update-lid}

      bindswitch lid:on output eDP-1 disable
      bindswitch lid:off output eDP-1 enable

      workspace number 1
      exec firefox
      workspace number 2
      exec kitty
      workspace number 9
      exec telegram-desktop
      exec ${launch} whatsapp
    '';
  };
}
