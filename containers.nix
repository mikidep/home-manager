{pkgs, ...}: {
  services.podman = {
    enable = true;
  };
  programs.distrobox = {
    enable = true;
    settings = {
      container_manager = "podman";
    };
  };
}
