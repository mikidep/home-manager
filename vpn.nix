{pkgs, ...}: {
  home.packages = with pkgs; [openfortivpn openfortivpn-webview];
}
