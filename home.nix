{
  pkgs,
  pkgs-stable,
  ...
}: {
  imports = [
    ./vscode.nix
    ./shell.nix
    ./ssh.nix
    ./design_tools.nix
    ./eid.nix
    ./nix-tools.nix
    ./agda.nix
    ./vpn.nix
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
    idris2
    stack
    archivemount
    trashy
    feh

    chromium
    discord
    telegram-desktop
    gimp
    vlc
    pkgs-stable.jabref
    inkscape
    signal-desktop
    ffmpeg_6-full
    audacity
    nerd-fonts.arimo
    nerd-fonts.iosevka
    nerd-fonts.iosevka-term
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    alsa-tools
    qpwgraph
    reaper
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = ["Arimo Nerd Font" "Noto Sans CJK CS"];
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
