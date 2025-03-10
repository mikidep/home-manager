{
  nix = {
    # settings.builders = [
    #   "eu.nixbuild.net x86_64-linux - 100 1 big-parallel,benchmark"
    # ];
    settings.builders-use-substitutes = true;
  };
}
