{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gcc-arm-embedded
    openocd
    tio
    ttylog
    # blackmagic
    # nrfutil
    nrf-command-line-tools
    (nrfutil.withExtensions [
      "nrfutil-nrf5sdk-tools"
      "nrfutil-device"
    ])
  ];
}
