{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    htop
    fortune
    zoxide
    bat
    killall
  ];
  programs.fish = {
    enable = true;
    functions = {
      nix_run = ''nix run nixpkgs#$argv[1] -- $argv[2..]'';
    };
    interactiveShellInit = let
      neovim-cmd = "nix run ~/dotfiles/neovim --";
      nix-your-shell = "${pkgs.nix-your-shell}/bin/nix-your-shell";
    in ''
      set fish_greeting # Disable greeting
      fish_add_path .local/bin/
      abbr --add ns --set-cursor "nix shell nixpkgs#%"
      abbr --add nix-list --set-cursor 'find $(nix build nixpkgs#% --print-out-paths --no-link) -print0 | ${pkgs.nnn}/bin/nnn'
      abbr --add nr --set-cursor "nix run nixpkgs#%"
      abbr --add nvim "${neovim-cmd}"
      abbr --add hm "home-manager --flake ~/dotfiles/home-manager"
      abbr --add hms "home-manager --flake ~/dotfiles/home-manager switch"
      abbr --add cat bat
      set EDITOR ${inputs.mikidep-neovim.packages.x86_64-linux.default}/bin/nvim
      zoxide init fish --cmd cd | source
      ${nix-your-shell} fish | source
    '';
    plugins = [
      {
        name = "nix-env";
        src = inputs.nix-env-fish;
      }
    ];
  };
  programs.nix-index.enable = true;
}
