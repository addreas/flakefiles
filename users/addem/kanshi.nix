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
        profile.name = "home-upstairs";
        profile.outputs = [
          {
            criteria = "Dell Inc. DELL U2725QE CK8YLF4";
            status = "enable";
            mode = "3840x2160";
            position = "0,0";
            scale = 1.25;
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
      }
      {
        profile.name = "home-downstairs";
        profile.outputs = [
          {
            criteria = "Samsung Electric Company LS27A800U HNMTA00128";
            status = "enable";
            mode = "3840x2160";
            position = "0,0";
            scale = 1.25;
          }
          {
            criteria = "eDP-1";
            status = "disable";
          }
        ];
      }];

  };
}
