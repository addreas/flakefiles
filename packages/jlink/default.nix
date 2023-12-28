{ stdenvNoCC
, lib
, fetchzip
, autoPatchelfHook
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
  '';


  meta = with lib; {
    description = "SEGGER JLink";
    homepage = "https://www.segger.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
  };
}

