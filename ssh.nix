{ home, ... }: { 
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        user = "git";
        host = "github.com";
        identityFile = "~/.ssh/id_ed25519";
      };
      ioc-michde = {
        user = "michde";
        host = "10.3.13.101";
        identityFile = "~/.ssh/michde-ioc";
      };
    };
  };
}
