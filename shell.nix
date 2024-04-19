{pkgs, ...}: {
  home.packages = with pkgs; [
    htop
    fortune

    killall
  ];
  programs.fish = {
    enable = true;
    functions = {
      nix_run = ''nix run nixpkgs#$argv[1] -- $argv[2..]'';
    };
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      fish_add_path .local/bin/
      # zoxide init fish | source
      abbr --add sg "${pkgs.shell_gpt}/bin/sgpt --repl temp --shell"
      abbr --add ns --set-cursor "nix shell nixpkgs#%"
      abbr --add nix-list --set-cursor 'find $(nix build nixpkgs#% --print-out-paths --no-link) -print0 | ${pkgs.nnn}/bin/nnn'
      abbr --add nr "nix_run"
      set EDITOR nvim
    '';
    plugins = [
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "85f863f";
          sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
        };
      }
      {
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
    ];
  };
  programs.nix-index.enable = true;
}
