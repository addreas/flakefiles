{ stdenvNoCC
, lib
, fetchzip
, autoPatchelfHook
, makeBinaryWrapper
, eudev
, qt48
}:
stdenvNoCC.mkDerivation rec {
  pname = "jlink";
  version = "V794b";

  src = fetchzip {
    url = "https://www.segger.com/downloads/jlink/JLink_Linux_${version}_x86_64.tgz";
    sha256 = "E/cIkV8JhLaTupNuU1xZbzlB3sRdRxbCK4BKChGYV4o=";
    curlOpts = "-d accept_license_agreement=accepted -d confirm=yes";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
  ];

  installPhase = ''
    mkdir -p $out/opt/SEGGER/JLink
    cp -r . $out/opt/SEGGER/JLink

    mkdir -p $out/lib/udev/rules.d
    cp 99-jlink.rules $out/lib/udev/rules.d

    rm $out/opt/SEGGER/JLink/libQtGui.so.4.8.7
    rm $out/opt/SEGGER/JLink/libQtCore.so.4.8.7

    ln -s ${qt48}/lib/libQtGui.so.4.8.7 $out/opt/SEGGER/JLink/libQtGui.so.4.8.7
    ln -s ${qt48}/lib/libQtCore.so.4.8.7 $out/opt/SEGGER/JLink/libQtCore.so.4.8.7

    mkdir $out/bin
    for f in $(find . -maxdepth 1 -type f -name 'J*Exe'); do
      ln -s $out/opt/SEGGER/JLink/$f $out/bin/$f
    done
  '';

  postFixup = ''
    for f in $(find . -maxdepth 1 -type f -name 'J*Exe'); do
      wrapProgram $out/opt/SEGGER/JLink/$f --prefix LD_LIBRARY_PATH : ${ lib.makeLibraryPath [eudev] }
    done
  '';


  meta = with lib; {
    description = "SEGGER JLink";
    homepage = "https://www.segger.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
  };
}

