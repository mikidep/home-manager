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
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";

    settings = {
      manager = {
        show_hidden = true;
      };
      preview = {
        max_width = 1000;
        max_height = 1000;
      };
    };

    plugins = {
      full-border = "${inputs.yazi-plugins}/full-border.yazi";
      max-preview = "${inputs.yazi-plugins}/max-preview.yazi";
      fuze-archive = "${inputs.fuse-archive-yazi}";
    };

    initLua = ''
      require("full-border"):setup()
    '';

    keymap = {
      manager.prepend_keymap = [
        {
          on = "T";
          run = "plugin --sync max-preview";
          desc = "Maximize or restore the preview pane";
        }
      ];
    };
  };
  programs.nix-index.enable = true;
}
