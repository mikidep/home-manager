{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        user = "git";
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519";
      };
      ioc-michde = {
        user = "michde";
        hostname = "10.3.13.101";
        identityFile = "~/.ssh/michde-ioc";
      };
      kspace-vps = {
        user = "mikidep";
        hostname = "193.40.103.105";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
      kspace-shared = {
        user = "kspace-shared";
        hostname = "193.40.103.105";
        identityFile = "~/.ssh/id_kspace_shared";
        identitiesOnly = true;
      };
    };
  };
}
