{ lib
, fetchzip
, buildFHSEnv

, qt5Full
, git
, git-lfs
, gnumake
, openssl
, ncurses
, jdk17
}:
let
  simplicity-studio = fetchzip {
    url = "https://www.silabs.com/documents/login/software/SimplicityStudio-5.tgz";
    sha256 = "xhSYOoQ9qX1/wpvDmmWTWFc8r2ThAl2k/bOMNcEI0cn=";
  };
in
buildFHSEnv rec {
  name = "simplicity-studio";

  targetPkgs = pkgs: with pkgs; [
    qt5Full
    git
    git-lfs
    gnumake
    openssl
    ncurses
    jdk17
    # simplicity-studio
  ];

  # runScript = "studiowayland.sh";

  meta = with lib; {
    description = "Simplicity Studio";
    homepage = "https://www.silabs.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
  };
}

