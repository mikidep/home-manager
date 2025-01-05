{pkgs, ...}: {
  home.packages = with pkgs; [
    (writeShellApplication {
      name = "ttuvpn";
      runtimeInputs = with pkgs; [
        openfortivpn
        openfortivpn-webview
      ];
      text = let
        vpnaddr = "vpn.taltech.ee:443";
        trcert = "dd7b28bce7714f20c2afb556e72d95e0bf3d10951eacecfd7aef4c00e00520fc";
      in ''
        openfortivpn-webview ${vpnaddr} 2>/dev/null \
        | sudo openfortivpn ${vpnaddr} --cookie-on-stdin --pppd-accept-remote --trusted-cert ${trcert}
      '';
    })
  ];
}
