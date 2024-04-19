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
    extensions = let
      vscodeExtPublisher = "banacorn";
      vscodeExtName = "agda-mode";
      agda-mode = pkgs.vscode-utils.buildVscodeExtension {
        name = "agda-mode";
        src = pkgs.fetchFromGitHub {
          owner = "banacorn";
          repo = "agda-mode-vscode";
          rev = "44e7dc4";
          hash = lib.fakeHash;
        };
        version = "0.4.1";
        inherit vscodeExtPublisher vscodeExtName;
        vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";
      };
    in
      with pkgs.vscode-extensions;
        [
          yzhang.markdown-all-in-one
          jnoortheen.nix-ide
          james-yu.latex-workshop
        ]
        # ++ [ agda-mode ]
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
          # {
          #   name = "agda-mode-fork";
          #   publisher = "GuilhermeEspada";
          #   version = "0.3.12";
          #   sha256 = "sha256-g1p3JjnkPYr2I7TRTClx5OYazyQxpkM6fnqiXWJoaSI=";
          # }
          {
            name = "agda-mode";
            publisher = "banacorn";
            version = "0.4.1";
            sha256 = "sha256-Zt2OifhS5BI0HcMZkKOa1gqV9Vpj0lIUR6VcHvX5M9o=";
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
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings".nil.formatting.command = [
        "${pkgs.alejandra}/bin/alejandra"
      ];
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
