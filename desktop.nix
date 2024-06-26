{
  pkgs,
  lib,
  ...
}: let
  bg = let
    convert = "${pkgs.imagemagick}/bin/convert";
    font = "${pkgs.iosevka}/share/fonts/truetype/Iosevka-ExtendedMediumItalic.ttf";
    bg = pkgs.runCommand "desktop-bg.png" {} ''
      ${convert} -font ${font} \
        -background black \
        -fill white \
        -pointsize 24 \
        -gravity center \
        -size 1920x1080 \
        label:"oh no, not you again!" $out
    '';
  in "${bg}";
in {
  # stylix = {
  #   image = bg;
  #   polarity = "dark";
  #   targets.kitty.enable = false;
  # };
  home.packages = with pkgs; [wl-clipboard];
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "layers.acceleration.force-enabled" = true;
        "gfx.webrender.all" = true;
        "gfx.webrender.enabled" = true;
        "layout.css.backdrop-filter.enabled" = true;
        "svg.context-properties.content.enabled" = true;
        "network.protocol-handler.external.mailto" = false;
      };
      userChrome = builtins.readFile ./assets/userChrome.css;
    };
  };

  programs.zathura.enable = true;
  programs.kitty = {
    enable = true;
  };

  imports = [
    ./sway.nix
  ];
  _module.args = {inherit bg;};
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

    desktopEntries.whatsapp = {
      type = "Application";
      name = "WhatsApp";
      comment = "Launch WhatsApp";
      icon = pkgs.fetchurl {
        url = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/WhatsApp.svg/240px-WhatsApp.svg.png";
        hash = "sha256-ZbTuq5taAsRvdfJqvqw8cqR5z4/Ogpt/nEb1npp/l4U=";
      };
      exec = ''${pkgs.chromium}/bin/chromium --app="https://web.whatsapp.com/"'';
      terminal = false;
    };
    desktopEntries.feh = {
      type = "Application";
      name = "Feh";
      comment = "Launch Feh";
      exec = ''${pkgs.feh}/bin/feh %U'';
      terminal = false;
    };
    mimeApps = {
      enable = true;
      defaultApplications = let
        constVals = ks: v: lib.attrsets.genAttrs ks (lib.trivial.const v);
      in
        {
          "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
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
