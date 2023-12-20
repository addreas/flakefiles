{ stdenvNoCC
, lib
, autoPatchelfHook
, fetchzip

, jdk
, python310Full

, libgcc
, libuuid
, libz
}:
let
  python = python310Full.withPackages (ps: [
    ps.numpy
    ps.scipy
  ]);
in
stdenvNoCC.mkDerivation rec {
  pname = "slc-cli";
  version = "5.8.0.0";

  src = fetchzip {
    url = "https://www.silabs.com/documents/login/software/slc_cli_linux.zip";
    sha256 = "kfsxw+7XcqtA4JVGo8QFf573Hu+C4p2B1VcLkyjQU8Y=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    libgcc
    libuuid
    libz
 ];


  buildInputs = [
    python
    jdk
  ];

  buildPhase = ''
    mkdir -p $out/bin
    echo "
    #!/usr/bin/env bash
    ${jdk}/bin/java -jar $out/share/slc-cli/slc.jar --slc-location $out/share/slc-cli "\$@"
    " > $out/bin/slc

    chmod +x $out/bin/slc

    mkdir -p $out/share/slc-cli
    cp $src/slc.jar $out/share/slc-cli

    cp -r $src/bin/slc-cli/{about.html,artifacts.xml,configuration,features,icon.xpm,META-INF,p2,plugins,slc-cli,slc-cli.ini} $out/share/slc-cli

    mkdir -p $out/share/slc-cli/developer/adapter_packs/python

    cp -r $src/bin/slc-cli/developer/adapter_packs/python/jep $out/share/slc-cli/developer/adapter_packs/python/jep

    ln -s ${python}/bin $out/share/slc-cli/developer/adapter_packs/python/bin
    ln -s ${python}/lib $out/share/slc-cli/developer/adapter_packs/python/lib
    ln -s ${python}/include $out/share/slc-cli/developer/adapter_packs/python/include
    ln -s ${python}/site-packages $out/share/slc-cli/developer/adapter_packs/python/ext-site-packages
    '';

  autoPatchelfLibs = ["${jdk}/lib/openjdk/lib/server"];

  meta = with lib; {
    description = "Silicon Labs Configurator (SLC)";
    homepage = "https://www.silabs.com/";
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ];
  };
}

