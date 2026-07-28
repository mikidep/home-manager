{bg, ...}: {
  programs.noctalia = {
    enable = true;
    settings = {
      general = {
        animationDisabled = true;
      };
      bar = {
        density = "compact";
        position = "bottom";
        showCapsule = false;
        outerCorners = false;
        widgets = {
          left = [
            {
              hideUnoccupied = false;
              id = "Workspace";
              labelMode = "medium";
              pillSize = 1;
            }
          ];
          center = [
            {
              id = "ActiveWindow";
              maxWidth = 2000;
            }
          ];
          right = [
            {
              id = "SystemMonitor";
              compactMode = false;
              showCpuUsage = false;
              showCpuTemp = false;
              showMemoryAsPercent = true;
              showDiskUsage = true;
              showDiskUsageAsPercent = true;
            }
            {
              id = "Bluetooth";
            }
            {
              id = "Network";
            }
            {
              id = "Volume";
            }
            {
              id = "Battery";
              warningThreshold = 20;
            }
            {
              formatHorizontal = "ddd dd MMM HH:mm";
              formatVertical = "HH mm";
              id = "Clock";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
            {
              id = "ControlCenter";
              useDistroLogo = true;
            }
          ];
        };
      };
      colorSchemes.predefinedScheme = "Monochrome";
    };
  };

  home.file.".cache/noctalia/wallpapers.json" = {
    text = builtins.toJSON {
      defaultWallpaper = bg;
    };
  };
}
