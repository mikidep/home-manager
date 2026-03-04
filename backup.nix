{
  config,
  pkgs,
  ...
}: {
  programs.borgmatic = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "borgmatic";
      paths = [
        pkgs.borgmatic
      ];
      postBuild = ''
        cd $out
        mkdir share/systemd
        mv lib/systemd/system share/systemd/user
      '';
    };
    backups.main = let
      path = config.home.homeDirectory + "/Documents";
      exclude-gitignore = pkgs.writeScript "exclude-gitignore" ''
        find ${path} -type f -name ".gitignore" -printf "%h\n" | \
          xargs -I '{}' bash -c "egrep -v '^(\s*|#.*)$' \"{}/.gitignore\" | awk '{print \"{}/\" \$0}' " \
          > /tmp/exclude-backup
      '';
    in {
      location = {
        repositories = ["ssh://kspace-vps/~/documents-repo"];
        patterns = [
          "R ${path}"
          "- **/.git"
          "- **/result"
        ];
        extraConfig = {
          exclude_from = ["/tmp/exclude-backup"];
        };
      };
      hooks.extraConfig.commands = [
        {
          before = "action";
          when = ["create"];
          run = [
            (builtins.toString exclude-gitignore)
          ];
        }
      ];
    };
  };
}
