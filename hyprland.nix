{
  pkgs,
  config,
  bg,
  ...
}: {
  programs.waybar.style =
    (builtins.readFile "${pkgs.waybar}/etc/xdg/waybar/style.css")
    + ''
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
  wayland.windowManager.hyprland = {
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
      in
        [
          "SUPER, Q, killactive,"
          "SUPER, F, fullscreen, 1"
          "SUPER, RETURN, exec, kitty"
          "SUPER, SPACE, exec, ${rofi-menu}"
          "ALT, F2, exec, ${rofi-run}"
        ]
        ++ (let
          arrowBinds = {
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
            "CTRL ALT, N,        workspace, emptym"
            "CTRL ALT SHIFT, ${left},  movetoworkspace, m-1"
            "CTRL ALT SHIFT, ${right}, movetoworkspace, m+1"
            "CTRL ALT SHIFT, ${up},    movewindow, mon:-1"
            "CTRL ALT SHIFT, ${down},  movewindow, mon:+1"
            "CTRL ALT SHIFT, N,        movetoworkspace, emptym"
          ];
        in
          (arrowBinds {
            left = "left";
            down = "down";
            up = "up";
            right = "right";
          })
          ++ (arrowBinds {
            left = "H";
            down = "J";
            up = "K";
            right = "L";
          }));
    };
  };
}
