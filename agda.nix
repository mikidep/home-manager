{pkgs, ...}: {
  home.packages = with pkgs; [
    (agda.withPackages (p: [
      p.cubical
      p.standard-library
    ]))
  ];
  systemd.user.slices.agda = {
    Slice = {
      MemoryHigh = "65%";
    };
  };
}
