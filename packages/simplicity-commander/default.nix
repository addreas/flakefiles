{ stdenvNoCC
, lib
, fetchzip
, autoPatchelfHook

, qt5Full

, jlink
}:
stdenvNoCC.mkDerivation rec {
  pname = "simplicity-commander";
  version = "1.16.3";

  src = fetchzip {
    url = "https://www.silabs.com/documents/login/software/SimplicityCommander-Linux.zip";
    sha256 = "xhSYOoQ9qX1/wpvDmmWTWFc8r2ThAl2k/bOMNcEI0cM=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    jlink
    qt5Full
  ];

  installPhase = ''
    tar xvf $src/Commander_linux_x86_64_*.tar.bz
    cp -r commander/ $out
  '';


  meta = with lib; {
    description = "Simplicity Commander";
    homepage = "https://www.silabs.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
  };
}

