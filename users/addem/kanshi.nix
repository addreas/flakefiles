{ pkgs, lib, ... }:
{
  services.kanshi = {
    enable = true;
    settings = [{
      profile.name = "internal";
      profile.outputs = [{
          criteria = "eDP-1";
          status = "enable";
          scale = 1.5;
        }];
    }
    {
      profile.name = "home";
      profile. outputs = [
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
          }
        ];
    }];

  };
}
