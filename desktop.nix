{
  pkgs,
  lib,
  nur,
  config,
  ...
}: let
  bg = let
    convert = "${pkgs.imagemagick}/bin/convert";
    font = "${pkgs.iosevka}/share/fonts/truetype/Iosevka-ExtendedMediumItalic.ttf";
    drv = pkgs.runCommand "desktop-bg.png" {} ''
      ${convert} -font ${font} \
        -background black \
        -fill white \
        -pointsize 24 \
        -gravity center \
        -size 1920x1080 \
        label:"oh no, not you again!" $out
    '';
  in
    drv.outPath;
  # could this be refactored using xdg terminal?
  terminal = assert config.programs.kitty.enable; "kitty";
in {
  imports = [
    ./sway.nix
    ./firefox.nix
  ];
  _module.args = {
    inherit bg terminal;
  };
  home.packages = with pkgs; [
    wl-clipboard
    gnome-calculator
    chromium
    telegram-desktop
    gimp
    vlc
    jabref
    feh
    inkscape
    signal-desktop
    qpwgraph
    reaper
    audacity
    (
      pkgs.writeShellApplication {
        name = "whatsapp";
        runtimeInputs = with pkgs; [chromium];
        text = ''chromium --ozone-platform-hint=auto --app="https://web.whatsapp.com/"'';
      }
    )
  ];

  i18n.inputMethod = {
    enabled = null;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      kdePackages.fcitx5-qt
      kdePackages.fcitx5-chinese-addons
    ];
  };

  programs.zathura.enable = true;

  programs.kitty = {
    enable = true;
    settings = {
      scrollback_pager = ''nvim -c "silent write! /tmp/kitty_scrollback_buffer | te cat /tmp/kitty_scrollback_buffer - "'';
    };
    keybindings = {
      # "f1" = "show_scrollback";
    };
    font.name = "Iosevka Term NFM";
    font.size = 16;
  };

  systemd.user.startServices = true;
  systemd.user.sessionVariables = {
    GTK_IM_MODULE = "fcitx5";
    QT_IM_MODULE = "fcitx5";
  };

  services.udiskie.enable = true;
  xdg = {
    enable = true;

    configFile = {
      "pipewire/pipewire-pulse.conf.d/switch-on-connect.conf".text = ''
        pulse.cmd = [
            { cmd = "load-module" args = "module-switch-on-connect" }
        ]
      '';
    };

    # Adapted from
    # https://github.com/cunbidun/dotfiles/blob/e1577d2335575d331365306c83e2d9d46d17d947/nix/hosts/nixos/home.nix
    portal = {
      enable = true;
      # xdgOpenUsePortal = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-termfilechooser
        xdg-desktop-portal-gtk
      ];
    };
    portal.config = {
      common.default = ["gtk"];
      common."org.freedesktop.impl.portal.FileChooser" = ["termfilechooser"];
    };
    # TODO: doesn't work

    desktopEntries.whatsapp = {
      type = "Application";
      name = "WhatsApp";
      comment = "Launch WhatsApp";
      icon = pkgs.fetchurl {
        url = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/WhatsApp.svg/240px-WhatsApp.svg.png";
        hash = "sha256-ZbTuq5taAsRvdfJqvqw8cqR5z4/Ogpt/nEb1npp/l4U=";
      };
      exec = ''whatsapp'';
      terminal = false;
    };
    desktopEntries.feh = {
      type = "Application";
      name = "Feh";
      comment = "Launch Feh";
      exec = "${lib.getExe pkgs.feh} %U";
      terminal = false;
    };
    desktopEntries.yazi = {
      type = "Application";
      name = "Yazi";
      comment = "Launch Yazi";
      exec = assert config.programs.yazi.enable; assert config.programs.kitty.enable; "kitty --hold yazi %U";
      terminal = false;
    };
    mimeApps = {
      enable = true;
      defaultApplications = let
        constVals = ks: v: lib.attrsets.genAttrs ks (lib.trivial.const v);
      in
        {
          "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
          "inode/directory" = "yazi.desktop";
        }
        // (constVals [
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "text/html"
          "application/x-extension-htm"
          "application/x-extension-html"
          "application/x-extension-shtml"
          "application/xhtml+xml"
          "application/x-extension-xhtml"
          "application/x-extension-xht"
        ] "firefox.desktop")
        // (constVals (map (s: "image/" + s) [
          "jpeg"
          "png"
          "gif"
          "tiff"
          "bmp"
        ]) "feh.desktop");
    };
  };
}
