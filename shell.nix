{
  pkgs,
  inputs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    htop
    fortune
    zoxide
    bat
    killall
    screen
    # inputs.mikidep-neovim.packages.x86_64-linux.default
    neovim
  ];
  programs.fish = {
    enable = true;
    functions = {
      nix_run = ''nix run nixpkgs#$argv[1] -- $argv[2..]'';
    };
    interactiveShellInit = let
      nix-your-shell = lib.getExe pkgs.nix-your-shell;
    in ''
      set fish_greeting # Disable greeting
      fish_add_path .local/bin/
      abbr --add ns --set-cursor "nix shell nixpkgs#%"
      abbr --add nl --set-cursor 'find $(nix build nixpkgs#% --print-out-paths --no-link) -print0 | ${lib.getExe pkgs.nnn}'
      abbr --add nr --set-cursor "nix run nixpkgs#%"
      abbr --add hms "home-manager --flake ~/dotfiles/home-manager switch"
      abbr --add nvm "nix run ~/dotfiles/neovim --"
      abbr --add cat bat
      set EDITOR nvim
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
  programs.starship = {
    enable = true;
    settings = {
      character = {
        success_symbol = "[❄](bold bright-blue)";
        error_symbol = "[❄](bold red)";
      };
      directory = {
        truncate_to_repo = false;
        truncation_symbol = "…/";
        fish_style_pwd_dir_length = 3;
      };
    };
  };
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";

    settings = {
      preview = {
        max_width = 1000;
        max_height = 1000;
      };
    };

    plugins = {
      full-border = "${inputs.yazi-plugins}/full-border.yazi";
      max-preview = "${inputs.yazi-plugins}/max-preview.yazi";
      fuse-archive = "${inputs.fuse-archive-yazi}";
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
