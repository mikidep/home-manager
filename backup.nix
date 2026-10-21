{
  config,
  pkgs,
  ...
}: {
  programs.borgmatic = {
    # TODO: broken
    # ~ systemd-analyze --user verify borgmatic.service
    # borgmatic.timer: Failed to open /home/mikidep/.config/systemd/user/borgmatic.timer: No such file or directory
    # Also SSH shenanigans
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
      exclude-gitignore = (
        pkgs.writeShellApplication {
          name = "exclude-gitignore";
          text = ''
            find ${path} -type f -name ".gitignore" -printf "%h\n" | \
              xargs -I '{}' bash -c "egrep -v '^(\s*|#.*)$' \"{}/.gitignore\" | awk '{print \"{}/\" \$0}' " \
              > /tmp/exclude-backup
          '';
        }
      );
    in {
      settings = {
        repositories = ["ssh://kspace-vps/~/documents-repo"];
        patterns = [
          "R ${path}"
          "- **/.git"
          "- **/result"
        ];
        commands = [
          {
            before = "action";
            when = ["create"];
            run = ["${exclude-gitignore}/bin/exclude-gitignore"];
          }
        ];
        exclude_from = ["/tmp/exclude-backup"];
      };
    };
  };
}
