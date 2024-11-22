{pkgs, ...}: {
  home.packages = with pkgs; [
    opensc
    web-eid-app
  ];
  programs.firefox = {
    package = pkgs.firefox-esr;
    nativeMessagingHosts = [
      pkgs.web-eid-app
    ];
  };
}
