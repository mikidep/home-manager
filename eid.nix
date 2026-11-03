{
  pkgs,
  nur,
  ...
}: {
  home.packages = with pkgs; [
    opensc
    web-eid-app
    qdigidoc
  ];
  programs.firefox = {
    nativeMessagingHosts = [
      pkgs.web-eid-app
    ];
    profiles.default.extensions.packages = with nur.repos.rycee.firefox-addons; [
      web-eid
    ];
  };
}
