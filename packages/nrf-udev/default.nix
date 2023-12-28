{ stdenvNoCC
, lib
, fetchFromGitHub
}:
stdenvNoCC.mkDerivation rec {
  pname = "nrf-udev";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "NordicSemiconductor";
    repo = pname;
    rev = "v${version}";
    sha256 = "bEIAsz9ZwX6RTzhv5/waFZ5a3KlnwX4kQs29+475zN0=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    mv */lib $out
  '';


  meta = with lib; {
    description = "udev rules for nRF (Nordic Semiconductor) development kits";
    homepage = "https://github.com/NordicSemiconductor/nrf-udev";
    # platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
  };
}

