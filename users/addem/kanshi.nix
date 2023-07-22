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

      home = {
        outputs = [
          {
            criteria = "Samsung Electric Company LS27A800U HNMTA00128";
            status = "enable";
            mode = "3840x2160";
            scale = 1.5;
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
      };
    };
  };
}
