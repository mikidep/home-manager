{pkgs, ...}: {
  home.packages = with pkgs; [
    nix-tree
  ];
}
