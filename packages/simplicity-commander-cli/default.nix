{ stdenvNoCC
, lib
, fetchzip
, autoPatchelfHook
, makeBinaryWrapper

, qt5Full
, eudev
}:
stdenvNoCC.mkDerivation rec {
  pname = "simplicity-commander-cli";
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

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
     tar xvf $src/Commander-cli_linux_x86_64_*.tar.bz
    
     mkdir -p $out/share
     cp -r commander-cli/ $out/share/simplicity-commander-cli

    wrapProgram $out/share/simplicity-commander-cli/commander-cli --prefix LD_LIBRARY_PATH : ${ lib.makeLibraryPath [eudev] }

     mkdir $out/bin
     ln -s $out/share/simplicity-commander-cli/commander-cli $out/bin/simplicity-commander-cli
  '';


  meta = with lib; {
    description = "Simplicity Commander CLI";
    homepage = "https://www.silabs.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
  };
}

