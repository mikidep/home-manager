{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    htop
    fortune
    autojump
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
    in ''
      set fish_greeting # Disable greeting
      fish_add_path .local/bin/
      # zoxide init fish | source
      abbr --add ns --set-cursor "nix shell nixpkgs#%"
      abbr --add nix-list --set-cursor 'find $(nix build nixpkgs#% --print-out-paths --no-link) -print0 | ${pkgs.nnn}/bin/nnn'
      abbr --add nr --set-cursor "nix run nixpkgs#%"
      abbr --add nvim "${neovim-cmd}"
      abbr --add hm "home-manager --flake ~/dotfiles/home-manager"
      abbr --add hms "home-manager --flake ~/dotfiles/home-manager switch"
      abbr --add cat bat
      set EDITOR "nix run github:mikidep/neovim --"
    '';
    plugins = [
      {
        name = "nix-env.fish";
        src = inputs.nix-env-fish;
      }
    ];
  };
  programs.nix-index.enable = true;
}
