{ stdenvNoCC
, lib
, makeBinaryWrapper

, freecad-wayland
, python311
, graphviz
}:
let
  freecad = freecad-wayland;
  pyenv = (python311.withPackages (ps: with ps; [
      ifcopenshell
      requests
      lark
    ]));
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
      --set PYTHONPATH ${ pyenv.sitePackages } \
      --prefix PATH : ${ lib.makeBinPath [graphviz] }

    makeWrapper ${freecad}/bin/FreeCADCmd $out/bin/FreeCADCmd \
      --set PYTHONPATH ${ pyenv.sitePackages } \
      --prefix PATH : ${ lib.makeBinPath [graphviz] }

    ln -s $out/bin/FreeCAD $out/bin/freecad 
    ln -s $out/bin/FreeCADCmd $out/bin/freecadcmd 
  '';

  meta = freecad.meta;
}
