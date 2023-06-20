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
            position = "0,1080";
          }];
      };

      home = {
        outputs = [
          {
            criteria = "Samsung Electric Company LS27A800U HNMTA00128";
            status = "enable";
            mode = "3840x2160";
            position = "0,0";
            scale = 1.5;
          }
          {
            criteria = "eDP-1";
            status = "disable";
            # position = "0,2160";
          }
        ];
      };
    };
  };
}
