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
    yazi
    screen
    (
      pkgs.writeShellApplication {
        name = "agda-search-stdlib";
        runtimeInputs = with pkgs; [fzf firefox sqlite];
        text = let
          docset = inputs.agda-docsets.packages.x86_64-linux.standard-library-docset;
        in ''
          sqlite3 ${docset}/standard-library.docset/Contents/Resources/docSet.dsidx "select * from searchIndex" \
            | fzf \
            | cut -d '|' -f 4 \
            | xargs -I % firefox --new-window file://${docset}/standard-library.docset/Contents/Resources/Documents/%
        '';
      }
    )
    (
      pkgs.writeShellApplication {
        name = "agda-search-cubical";
        runtimeInputs = with pkgs; [fzf firefox sqlite];
        text = let
          docset = inputs.agda-docsets.packages.x86_64-linux.cubical-docset;
        in ''
          sqlite3 ${docset}/cubical.docset/Contents/Resources/docSet.dsidx "select * from searchIndex" \
            | fzf \
            | cut -d '|' -f 4 \
            | xargs -I % firefox --new-window file://${docset}/cubical.docset/Contents/Resources/Documents/%
        '';
      }
    )
  ];
  programs.fish = {
    enable = true;
    functions = {
      nix_run = ''nix run nixpkgs#$argv[1] -- $argv[2..]'';
      y = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        	builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      '';
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
