{ pkgs, lib, ... }:
{
  services.kanshi = {
    enable = true;
    profiles = {
      internal = {
        outputs = [{
          criteria = "eDP-1";
          status = "enable";
          scale = 1.5;
        }];
      };

      thirty-four-inches = {
        outputs = [{
          criteria = "Dell Inc. DELL U3421WE 50F6753";
          status = "enable";
          mode = "3440x1440";
          position = "1920,0";
        }
        {
          criteria = "eDP-1";
          status = "disable";
          position =  "0,1080";
        }];
      };

      home = {
        outputs = [
          {
            criteria = "Unknown 2269WM BCPD59A000079";
            status = "enable";
            mode = "1920x1080";
            position = "0,0";
          }
          {
            criteria = "eDP-1";
            status = "enable";
            position = "1920,540";
          }
        ];
      };
    };
  };
}
