{ lib
, fetchFromGitHub
, rustPlatform
, autoPatchelfHook
, makeBinaryWrapper
, libgcc
, libxkbcommon
, wayland
, xorg
, pop-launcher
}:

rustPlatform.buildRustPackage rec {
  pname = "onagre";
  version = "1.0.0-alpha.0-7fef4ce";

  src = fetchFromGitHub {
    owner = "onagre-launcher";
    repo = pname;
    rev = "7fef4ce531a5fb948b24eb4541d812ce989305d7";
    hash = "sha256-r8VXbmlj4pOKhoeq1YNyd9P/sMFZgmugbGfUjoBNrTA=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "onagre-launcher-plugins-1.2.3" = "sha256-2w6JqFkmnTrTd84o0S7J0AwiVttwQJH9uTcQRyqBXjM=";
    };
  };

  nativeBuildInputs = [ autoPatchelfHook makeBinaryWrapper ];

  buildInputs = [ libgcc ];

  runtimeDependencies = lib.makeLibraryPath [
    wayland
    libxkbcommon
    xorg.libXcursor
    xorg.libX11
  ];

  postFixup = ''
    wrapProgram $out/bin/onagre\
      --prefix PATH : ${lib.makeBinPath [ pop-launcher ]}
  '';

  meta = with lib; {
    description = "A general purpose application launcher for X and wayland inspired by rofi/wofi and alfred";
    homepage = "https://github.com/oknozor/onagre";
    license = licenses.mit;
    maintainers = [ maintainers.jfvillablanca ];
    platforms = platforms.linux;
  };
}
