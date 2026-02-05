{
  pkgs,
  lib,
  nur,
  ...
}: {
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = with pkgs; [
      tridactyl-native
    ];
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
        "browser.tabs.unloadOnLowMemory" = true;
        "browser.autofocus" = false;
        "browser.ml.chat.enabled" = false;
        "browser.search.region" = "IT";
        "sidebar.verticalTabs" = true;

        # Do you sometimes experience Firefox randomly going back?
        "ui.context_menus.after_mouseup" = true;
      };

      extensions.packages = with nur.repos.rycee.firefox-addons; [
        ublock-origin
        youtube-nonstop
        tridactyl
        privacy-badger
        consent-o-matic
        sponsorblock
      ];
      userChrome = ''
        #statuspanel {
          right: 0 !important;
          left: auto !important;
          max-width: 50% !important;
        }
      '';
    };
  };
  xdg.configFile."tridactyl/tridactylrc".text =
    ''
      bind J tabnext
      bind K tabprev
      bind / fillcmdline find
      bind ? fillcmdline find --reverse
      bind n findnext --search-from-view
      bind N findnext --search-from-view --reverse
      bind ;a composite hint -F a => a.getAttribute('href') | yank
      bind f hint -J
      # bind F hint -Jbc a

      set smoothscroll true
      set blacklistkeys ['/']

      bindurl www.google.com f hint -Jc #search a
      bindurl www.google.com F hint -Jbc #search a
    ''
    + (lib.concatMapStrings (url: ''
        autocmd DocStart ${url} mode ignore
      '') [
        "tinder.com/app/recs"
        "q.uiver.app"
      ]);
}
