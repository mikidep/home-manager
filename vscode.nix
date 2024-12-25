{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    clang-tools
  ];
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions;
      [
        yzhang.markdown-all-in-one
        jnoortheen.nix-ide
        james-yu.latex-workshop
        banacorn.agda-mode
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
          version = "0.47.2";
          sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
        }
        {
          name = "vscode-pitch-black-theme";
          publisher = "viktorqvarfordt";
          version = "1.3.0";
          sha256 = "sha256-1JDm/cWNWwxa1gNsHIM/DIvqjXsO++hAf0mkjvKyi4g=";
        }
        {
          name = "yuck";
          publisher = "eww-yuck";
          version = "0.0.3";
          sha256 = "sha256-DITgLedaO0Ifrttu+ZXkiaVA7Ua5RXc4jXQHPYLqrcM=";
        }
        {
          name = "openscad-language-support";
          publisher = "Leathong";
          version = "1.2.5";
          sha256 = "sha256-/CLxBXXdUfYlT0RaGox1epHnyAUlDihX1LfT5wGd2J8=";
        }
        {
          name = "idris-vscode";
          publisher = "meraymond";
          version = "0.0.14";
          sha256 = "sha256-QAzjm+8Z+4TDbM5amh3UEkSmp0n8ZlRHYpUGAewIVXk=";
        }
      ];
    userSettings = {
      "workbench.colorTheme" = "Pitch Black";

      "editor.fontFamily" = "Iosevka";
      "editor.fontLigatures" = true;
      "editor.fontSize" = 18;
      "editor.mouseWheelZoom" = true;

      "window.commandCenter" = true;
      "window.titleBarStyle" = "custom";
      "window.menuBarVisibility" = "compact";

      "security.workspace.trust.enabled" = false;
      "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
      "[agda]" = {
        "editor.tabSize" = 2;
        "editor.unicodeHighlight.ambiguousCharacters" = false;
      };
      "explorer.excludeGitIgnore" = true;

      "nix.enableLanguageServer" = true;
      "nix.serverPath" = lib.getExe pkgs.nixd;
      "nix.serverSettings".nixd.formatting.command = [(lib.getExe pkgs.alejandra)];
      "idris.idris2Mode" = true;
      "idris.idrisPath" = "idris2";
    };
    languageSnippets = {
      agda = {
        "Declare and define" = {
          prefix = "def";
          body = [
            "\${1:aux} : ?"
            "\${1:aux} = ?$2"
          ];
        };
      };
    };
    keybindings = let
      typingBindings =
        map
        ({
          key,
          text,
        }: {
          inherit key;
          when = "editorLangId == agda";
          command = "type";
          args = {
            inherit text;
          };
        }) [
          {
            key = "Alt+0";
            text = "₀";
          }
          {
            key = "Alt+1";
            text = "₁";
          }
          {
            key = "Alt+2";
            text = "₂";
          }
          {
            key = "Alt+3";
            text = "₃";
          }
          {
            key = "Alt+Shift+N";
            text = "ℕ";
          }
          {
            key = "Alt+Shift+2";
            text = "𝟚";
          }
          {
            key = "Alt+Shift+A";
            text = "∀";
          }
          {
            key = "Alt+Shift+E";
            text = "∃";
          }
          {
            key = "Alt+Shift+0";
            text = "≡";
          }
          {
            key = "Alt+Shift+.";
            text = "→";
          }
          {
            key = "Alt+Shift+,";
            text = "≤";
          }
          {
            key = "Alt+L";
            text = "λ";
          }
          {
            key = "Alt+Shift+S";
            text = "Σ";
          }
          {
            key = "Alt+Shift+D";
            text = "Δ";
          }
          {
            key = "Alt+A";
            text = "α";
          }
          {
            key = "Alt+B";
            text = "β";
          }
          {
            key = "Alt+H";
            text = "η";
          }
          {
            key = "Alt+I";
            text = "ι";
          }
          {
            key = "Alt+L";
            text = "λ";
          }
          {
            key = "Alt+M";
            text = "μ";
          }
          {
            key = "Alt+N";
            text = "ν";
          }
          {
            key = "Alt+P";
            text = "π";
          }
          {
            key = "Alt+T";
            text = "τ";
          }
          {
            key = "Alt+W";
            text = "ω";
          }
          {
            key = "Alt+Y";
            text = "よ";
          }

          {
            key = "Alt+;";
            text = "；";
          }
          {
            key = "Alt+Shift+3";
            text = "≈";
          }
          {
            key = "NumPad6";
            text = "→";
          }
        ];
    in
      typingBindings
      ++ [
        {
          key = "ctrl+x ctrl+=";
          command = "-agda-mode.lookup-symbol";
          when = "!terminalFocus && editorLangId == 'agda' || !terminalFocus && editorLangId == 'lagda-md' || !terminalFocus && editorLangId == 'lagda-rst' || !terminalFocus && editorLangId == 'lagda-tex'";
        }
      ];
  };
}
