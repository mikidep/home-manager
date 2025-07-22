{
  inputs,
  system,
  pkgs,
  lib,
  config,
  bg,
  terminal,
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
  imports = [./sway/portal.nix];
  nixpkgs.overlays = [
    (_: prev: {
      sway-new-workspace = inputs.sway-new-workspace.packages.${system}.default;
      swayws = let
        pkg = {
          lib,
          rustPlatform,
        }:
          rustPlatform.buildRustPackage {
            pname = "swayws";
            version = "1.2.0-mikidep";
            src = inputs.swayws-src;
            cargoLock.lockFile = "${inputs.swayws-src}/Cargo.lock";

            # swayws does not have any tests
            doCheck = false;

            meta = with lib; {
              description = "Sway workspace tool which allows easy moving of workspaces to and from outputs";
              mainProgram = "swayws";
              homepage = "https://github.com/mikidep/swayws";
              license = licenses.mit;
              maintainers = [maintainers.atila];
            };
          };
      in
        pkgs.callPackage pkg {};
    })
  ];
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

  programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
      indicator-idle-visible = true;
    };
  };

  services.swayidle = let
    swaylock = lib.getExe pkgs.swaylock;
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
    rofi-pm = lib.getExe pkgs.rofi-power-menu;
    rofi-menu = ''${rofi} -show combi -combi-modes "pm:${rofi-pm},window,drun" -show-icons -theme solarized'';
    rofi-run = ''${rofi} -show run -theme solarized'';
    inherit terminal; # redundant
  in {
    enable = true;
    package = let
      cfg = config.wayland.windowManager.sway;
    in
      (pkgs.sway.overrideAttrs {
        version = "1.10";
      })
      .override {
        extraSessionCommands = cfg.extraSessionCommands;
        extraOptions = cfg.extraOptions;
        withBaseWrapper = cfg.wrapperFeatures.base;
        withGtkWrapper = cfg.wrapperFeatures.gtk;
      };
    systemd.enable = true;

    wrapperFeatures = {
      base = true;
      gtk = true;
    };

    config = {
      input."*" = {
        xkb_layout = "us(altgr-intl)";
        xkb_numlock = "enabled";
        xkb_options = "caps:escape";
        tap = "enabled";
        tap_button_map = "lrm";
      };

      input."1:1:AT_Translated_Set_2_keyboard" = {
        xkb_layout = "it";
      };

      keybindings =
        (
          let
            sway-workspace = let
              repo = inputs.sway-workspace;
              pkg = pkgs.rustPlatform.buildRustPackage {
                name = "sway-workspace";
                src = repo;
                cargoLock.lockFile = "${repo}/Cargo.lock";
              };
            in
              lib.getExe' pkg "sway-workspace";
            swayws = lib.getExe pkgs.swayws;
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
            sway-nw = lib.getExe' pkgs.sway-new-workspace "sway-new-workspace";
            unmute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0";
            grimshot = lib.getExe pkgs.sway-contrib.grimshot;
            brightnessctl = lib.getExe pkgs.brightnessctl;
          in {
            "Ctrl+Alt+N" = "exec ${sway-nw} open";
            "Ctrl+Alt+Shift+N" = "exec ${sway-nw} move";
            "Alt+F2" = "exec ${rofi-run}";
            "Mod4+space" = "exec ${rofi-menu}";
            "Mod4+V" = "layout toggle all";
            "Mod4+S" = "split toggle";
            "Shift+Mod4+Q" = "kill";
            "Mod4+Return" = "exec ${terminal}";
            "Mod4+R" = "mode resize";
            "Mod4+F" = "floating toggle";

            "Print" = "exec ${grimshot} copy anything";
            "Shift+Print" = "exec ${grimshot} copy output";
            "XF86AudioRaiseVolume" = "exec ${unmute}; exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
            "XF86AudioLowerVolume" = "exec ${unmute}; exec wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";
            "XF86MonBrightnessUp" = "exec ${brightnessctl} s +10%";
            "XF86MonBrightnessDown" = "exec ${brightnessctl} s 10%-";
            "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          }
        );
      modes.resize = {
        "Escape" = "mode default";
        "L" = "resize grow width 10 px";
        "H" = "resize shrink width 10 px";
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
        "eDP-1" = {
          scale = "1.25";
        };
      };

      window.titlebar = false;

      assigns = {
        "20: IM" = [
          {title = "whatsapp";}
          {app_id = "telegram";}
        ];
      };
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
      startup = [
        {
          command = update-lid.outPath;
          always = true;
        }
        {
          command = let
            python-i3ipc = lib.getExe (pkgs.python312.withPackages (p: [p.i3ipc]));
          in "${python-i3ipc} ${inputs.i3-switch-if-workspace-empty}/i3-switch-if-workspace-empty";
          always = true;
        }
      ];
    };

    extraConfig = ''
      bindswitch lid:on  exec ${update-lid}
      bindswitch lid:off exec ${update-lid}

      bindsym --whole-window BTN_BACK nop
      bindsym --whole-window --release BTN_BACK nop
      bindsym --whole-window BTN_FORWARD nop
      bindsym --whole-window --release BTN_FORWARD nop
      bindsym --whole-window BTN_SIDE nop
      bindsym --whole-window --release BTN_SIDE nop
      bindsym --whole-window BTN_EXTRA nop
      bindsym --whole-window --release BTN_EXTRA nop

      workspace 1
      exec firefox
      workspace 2
      exec ${terminal}
      exec telegram-desktop
      exec whatsapp
    '';
  };
}
