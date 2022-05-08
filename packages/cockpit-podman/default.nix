{ lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "cockpit-podman";
  version = "47";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit-podman/releases/download/${version}/cockpit-podman-${version}.tar.xz";
    sha256 = "06anqm3im12sgnk16hfcp2h16xzlbxc0l7fq2b3n44bkfxhizjyx";
  };

  DESTDIR = out;

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
