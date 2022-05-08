{ lib, stdenv, fetchzip, gettext }:

stdenv.mkDerivation rec {
  pname = "cockpit-podman";
  version = "47";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit-podman/releases/download/${version}/cockpit-podman-${version}.tar.xz";
    sha256 = "RO10Ml+0H3pXnWnK8F5zqScMoV4KTK4+CbczTtTaj74=";
  };

  nativeBuildInputs = [ gettext ];

  makeFlags = [ "DESTDIR=$(out)" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace /usr/share /share
  '';

  meta = with lib; {
    description = "Cockpit UI for podman containers";
    license = licenses.lgpl21;
    homepage = "https://github.com/cockpit-project/cockpit-podman";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
