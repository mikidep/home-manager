{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  home.packages = with pkgs; [
    htop
    fortune
    zoxide
    bat
    killall
    screen
    inputs.mikidep-neovim.packages.x86_64-linux.default
    lazygit
  ];
  programs.fish = {
    enable = true;
    interactiveShellInit = let
      nix-your-shell = lib.getExe pkgs.nix-your-shell;
      file-manager = assert config.programs.yazi.enable; "yazi";
    in ''
      set fish_greeting # Disable greeting
      fish_add_path .local/bin/
      abbr --add ns --set-cursor "nix shell nixpkgs#%"
      abbr --add nl --set-cursor '${file-manager} $(nix build nixpkgs#% --print-out-paths --no-link)'
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
        max_width = 4000;
        max_height = 2000;
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
