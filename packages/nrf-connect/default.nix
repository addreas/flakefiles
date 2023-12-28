{ appimageTools
, fetchurl
, jlink
, nrf-udev
}:
appimageTools.wrapType2 {
  name = "nrf-connect";
  src = fetchurl {
    url = "https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-connect-for-desktop/4-3-0/nrfconnect-4.3.0-x86_64.appimage";
    hash = "sha256-G8//dZqPxn6mR8Bjzf/bAn9Gv7t2AFWIF9twCGbqMd8=";
  };
  extraPkgs = pkgs: with pkgs; [
    nrf-udev
    jlink
  ];
}
