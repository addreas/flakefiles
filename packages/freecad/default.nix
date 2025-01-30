{ stdenvNoCC
, lib
, makeBinaryWrapper

, freecad-git
, python311
, graphviz
, fontconfig
, freetype
}:
let
  freecad = freecad-git;
  pyenv = (python311.withPackages (ps: with ps; [
      # ifcopenshell
      requests
      lark
    ]));
  libpath = lib.makeLibraryPath [
      fontconfig
      freetype
    ];

  path = lib.makeBinPath [graphviz];
in
stdenvNoCC.mkDerivation rec {
  pname = "freecad-wrapped";
  version = freecad.version;

  dontUnpack = true;
  dontPatch = true;
  dontBuild = true;
  dontFixup = true;

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  installPhase = ''
    mkdir -p $out/bin

    for dir in doc  Ext  include  lib  Mod  share; do
      ln -s ${freecad}/$dir $out
    done

    makeWrapper ${freecad}/bin/FreeCAD $out/bin/FreeCAD \
      --set PYTHONPATH ${pyenv}/${pyenv.sitePackages} \
      --set LD_LIBRARY_PATH ${libpath} \
      --prefix PATH : ${path}

    makeWrapper ${freecad}/bin/FreeCADCmd $out/bin/FreeCADCmd \
      --set PYTHONPATH ${pyenv}/${pyenv.sitePackages} \
      --prefix PATH : ${path}

    ln -s $out/bin/FreeCAD $out/bin/freecad 
    ln -s $out/bin/FreeCADCmd $out/bin/freecadcmd 
  '';

  meta = freecad.meta;
}
