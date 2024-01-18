{ stdenvNoCC
, lib
, fetchzip
, autoPatchelfHook
, makeBinaryWrapper

, qt5Full
, eudev
}:
stdenvNoCC.mkDerivation rec {
  pname = "simplicity-commander";
  version = "1.16.3";

  src = fetchzip {
    url = "https://www.silabs.com/documents/public/software/SimplicityCommander-Linux.zip";
    sha256 = "xhSYOoQ9qX1/wpvDmmWTWFc8r2ThAl2k/bOMNcEI0cM=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
    qt5Full
  ];

  installPhase = ''
    tar xvf $src/Commander_linux_x86_64_*.tar.bz

    mkdir -p $out/share
    cp -r commander/ $out/share/simplicity-commander

    wrapProgram $out/share/simplicity-commander/commander --prefix LD_LIBRARY_PATH : ${ lib.makeLibraryPath [eudev] }

    mkdir -p $out/bin

    ln -s $out/share/simplicity-commander/commander $out/bin/simplicity-commander
  '';


  meta = with lib; {
    description = "Simplicity Commander";
    homepage = "https://www.silabs.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
  };
}

