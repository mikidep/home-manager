{
  pkgs,
  config,
  lib,
  bg,
  ...
}: {
  programs.waybar.style = ''
    #workspaces button.active {
       background-color: #64727D;
       box-shadow: inset 0 -3px #ffffff;
    }
  '';
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        bg
      ];
      wallpaper = [
        ", ${bg}"
      ];
    };
  };
  home.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
  };
  wayland.windowManager.hyprland = let
    vimbind = binder:
      (binder {
        left = "left";
        down = "down";
        up = "up";
        right = "right";
      })
      ++ (binder {
        left = "H";
        down = "J";
        up = "K";
        right = "L";
      });
  in {
    enable = true;
    settings = {
      input = {
        kb_layout = "it,us";
        kb_variant = ",altgr-intl";
        kb_options = "caps:swapescape";
        numlock_by_default = true;
        follow_mouse = false;
      };
      monitor = [
        "eDP-1, preferred, auto, 1"
      ];
      animation = [
        "global, 0"
        "workspaces, 1, 1, default"
      ];
      dwindle.force_split = 2;
      workspace = [
        "w[tv1], border:false"
      ];
      # env = [
      #   "XCURSOR_THEME,Vanilla-DMZ"
      #   "XCURSOR_SIZE,32"
      # ];
      general = {
        gaps_in = 2;
        gaps_out = 0;
      };
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        enable_anr_dialog = false;
      };

      exec-once = [
        "[workspace 1 silent] firefox"
        "[workspace 2 silent] kitty"
        "[workspace name:IM silent] whatsapp"
        "[workspace name:IM silent] Telegram"
      ];
      bind = assert config.programs.rofi.enable; let
        rofi-menu = ''rofi -show combi -combi-modes "pm,drun,window" -show-icons'';
        rofi-run = ''rofi -show run'';
        grimshot = lib.getExe pkgs.sway-contrib.grimshot;
      in
        [
          "SUPER, Q, killactive,"
          "SUPER, F, fullscreen, 1"
          "SUPER SHIFT, F, togglefloating,"
          "SUPER, RETURN, exec, kitty"
          "SUPER, SPACE, exec, ${rofi-menu}"
          "ALT, F2, exec, ${rofi-run}"
          ", Print, exec, ${grimshot} copy anything"
          "SHIFT, Print, exec, ${grimshot} copy output"
          "CTRL ALT, N,        workspace, emptym"
          "CTRL ALT SHIFT, N,        movetoworkspace, emptym"
          "SUPER, R, submap, resize"
        ]
        ++ vimbind ({
          up,
          down,
          left,
          right,
        }: [
          "SUPER, ${left},  movefocus, l"
          "SUPER, ${right}, movefocus, r"
          "SUPER, ${up},    movefocus, u"
          "SUPER, ${down},  movefocus, d"
          "SUPER SHIFT, ${left},  movewindow, l"
          "SUPER SHIFT, ${right}, movewindow, r"
          "SUPER SHIFT, ${up},    movewindow, u"
          "SUPER SHIFT, ${down},  movewindow, d"
          "CTRL ALT, ${left},  workspace, m-1"
          "CTRL ALT, ${right}, workspace, m+1"
          "CTRL ALT, ${up},  focusmonitor, -1"
          "CTRL ALT, ${down}, focusmonitor, +1"
          "CTRL ALT SHIFT, ${left},  movetoworkspace, m-1"
          "CTRL ALT SHIFT, ${right}, movetoworkspace, m+1"
          "CTRL ALT SHIFT, ${up},    movewindow, mon:-1"
          "CTRL ALT SHIFT, ${down},  movewindow, mon:+1"
        ]);

      bindl = let
        unmute = "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0";
        brightnessctl = lib.getExe pkgs.brightnessctl;
      in [
        ", XF86AudioRaiseVolume, exec, ${unmute} && wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, ${unmute} && wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, ${brightnessctl} s +10%"
        ", XF86MonBrightnessDown, exec, ${brightnessctl} s 10%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
    };
    submaps.resize.settings.bind =
      (vimbind ({
        up,
        down,
        left,
        right,
      }: [
        ", ${right}, resizeactive, 10 0"
        ", ${left}, resizeactive, -10 0"
        ", ${up}, resizeactive, 0 -10"
        ", ${down}, resizeactive, 0 10"
      ]))
      ++ [
        ", escape, submap, reset"
      ];
  };
}
