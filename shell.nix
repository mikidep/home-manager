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
    mmtui
  ];
  programs.fish = {
    enable = true;
    shellAbbrs = let
      file-manager = assert config.programs.yazi.enable; "yazi";
    in {
      hms = "home-manager --flake ~/dotfiles/home-manager switch";
      nvm = "nix run ~/dotfiles/neovim --";
      cat = "bat";
      gc = "git clone $(wl-paste)";
      "ns" = {
        expansion = "nix shell nixpkgs#%";
        setCursor = true;
      };
      "nl" = {
        expansion = "${file-manager} $(nix build nixpkgs#% --print-out-paths --no-link)";
        setCursor = true;
      };
      "nr" = {
        expansion = "nix run nixpkgs#%";
        setCursor = true;
      };
    };
    interactiveShellInit = let
      nix-your-shell = lib.getExe pkgs.nix-your-shell;
    in ''
      set fish_greeting # Disable greeting
      fish_add_path .local/bin/
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
      mount = "${inputs.mount-yazi}";
      fuse-archive = "${inputs.fuse-archive-yazi}";
    };

    initLua = ''
      require("full-border"):setup()

      Status:children_add(function(self)
      	local h = self._current.hovered
      	if h and h.link_to then
      		return " -> " .. tostring(h.link_to)
      	else
      		return ""
      	end
      end, 3300, Status.LEFT)
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
