{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./vscode.nix
    ./shell.nix
    ./ssh.nix
    ./design_tools.nix
    ./matterlabs.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mikidep";
  home.homeDirectory = "/home/mikidep";

  nixpkgs.config = {
    allowUnfree = true;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    (agda.withPackages (p: [p.cubical p.standard-library]))
    idris2
    stack
    archivemount
    nnn
    trashy
    feh

    chromium
    discord
    telegram-desktop
    gimp
    vlc
    jabref
    inkscape
    signal-desktop
    ffmpeg_6-full
    audacity
    (
      nerdfonts.override {
        fonts = ["Arimo" "Iosevka"];
      }
    )
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    alsa-tools
    qpwgraph
    reaper
    zeal
    glxinfo
  ];

  home.file.agda-docset-stdlib = {
    source = "${inputs.agda-docsets.packages.x86_64-linux.standard-library-docset}/standard-library.docset";
    target = ".local/share/Zeal/Zeal/docsets/standard-library.docset";
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = ["Noto Sans CJK CS" "Arimo NF"];
      monospace = ["IosevkaTerm NFM"];
    };
  };
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Michele De Pascalis";
    userEmail = "michele.de.pascalis.1024@gmail.com";
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      droidcam-obs
    ];
  };
}
