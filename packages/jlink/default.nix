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
    cp -r . $out

    rm $out/libQtGui.so.4.8.7
    rm $out/libQtCore.so.4.8.7

    ln -s ${qt48}/lib/libQtGui.so.4.8.7 $out/libQtGui.so.4.8.7
    ln -s ${qt48}/lib/libQtCore.so.4.8.7 $out/libQtCore.so.4.8.7
  '';


  meta = with lib; {
    description = "SEGGER JLink";
    homepage = "https://www.segger.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
  };
}

