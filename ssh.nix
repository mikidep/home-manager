{
  lib,
  config,
  ...
}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
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

  # # Introduced because Borgmatic SSH shenanigans
  #
  # home.activation.sshConfigMode = lib.hm.dag.entryAfter ["linkGeneration"] ''
  #   cfg="${config.home.homeDirectory}/.ssh/config"
  #   if [[ -L $cfg ]]; then
  #     real=$(readlink -f "$cfg")
  #     rm -f "$cfg"
  #     cp -f "$real" "$cfg"
  #     chmod 600 "$cfg"
  #   elif [[ -f $cfg ]]; then
  #     chmod 600 "$cfg"
  #   fi
  # '';
}
