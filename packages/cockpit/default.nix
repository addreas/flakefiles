{ lib
, stdenv
, fetchzip
, pkgconfig
, glib
, systemd
, json-glib
, gnutls
, krb5
, polkit
, libssh
, pam
, libxslt
, xmlto
, python3
, gnused
, coreutils
, makeWrapper
, openssl
, extraPackages ? [ ]
}:

let
  path = lib.makeSearchPath "bin" ([ "$out" "/run/wrappers" "/run/current-system/sw" ] ++ extraPackages);
in
stdenv.mkDerivation rec {
  pname = "cockpit";
  version = "267";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit/releases/download/${version}/cockpit-${version}.tar.xz";
    sha256 = "0bdc2qzqcz4k92asxip00nambn47a4w12c4vl08xj6nc1ja627ig";
  };

  configureFlags = [
    "--disable-doc"
    "--with-systemdunitdir=$(out)/lib/systemd/system"
    "--sysconfdir=/etc"
  ]
  ++ (if lib.any ({ name, ... }: name == "pcp") extraPackages then [ ] else [ "--disable-pcp" ]);

  nativeBuildInputs = [
    pkgconfig
    python3
    gnused
    makeWrapper
  ];

  buildInputs = [
    glib
    systemd
    json-glib
    gnutls
    krb5
    polkit
    libssh
    pam
    libxslt
    xmlto
  ] ++ extraPackages;

  patches = [
    ./fix_paths.patch
  ];

  inherit coreutils gnused openssh;

  postPatch = ''
    patchShebangs tools

    substituteAllInPlace src/bridge/bridge.c
    substituteAllInPlace src/bridge/org.cockpit-project.cockpit-bridge.policy.in

    substituteAllInPlace src/session/session-utils.h
  
    substituteAllInPlace src/systemd/cockpit.service.in
    substituteAllInPlace src/systemd/cockpit-wsinstance-http.service.in
    substituteAllInPlace src/systemd/cockpit-wsinstance-https-factory@.service.in
    substituteAllInPlace src/systemd/cockpit-wsinstance-https@.service.in
    substituteAllInPlace src/systemd/update-motd

    substituteAllInPlace src/pam-ssh-add/pam-ssh-add.c
  '';

  configureFlags = [
    "--disable-doc"
    "--with-systemdunitdir=$(out)/etc/systemd/system"
    # "--with-cockpit-user=cockpit-ws"
    # "--with-cockpit-ws-instance-user=cockpit-wsinstance"
    "--enable-debug"
    "SSH_ADD=${openssh}/bin/ssh-add"
    "SSH_AGENT=${openssh}/bin/ssh-agent"
  ]
  ++ (if lib.any ({ name, ... }: name == "pcp") extraPackages then [ ] else [ "--disable-pcp" ]);


  buildPhase = ''
    ./tools/adjust-distdir-timestamps .

     make install
  '';

  postPatch = ''
    patchShebangs tools
    sed -r '/^cmd_make_package_lock_json\b/ a exit 0' -i tools/node-modules
    substituteInPlace Makefile.in \
      --replace "\$(DESTDIR)\$(sysconfdir)" "$out/etc"
    substituteInPlace src/session/session-utils.h \
      --replace "DEFAULT_PATH \"" "DEFAULT_PATH \"${path}:"
  '';

  postInstall = ''
    wrapProgram "$out/libexec/cockpit-certificate-helper" \
      --suffix PATH : "${lib.makeBinPath [ coreutils openssl ]}"
  '';

  meta = with lib; {
    description = "Web-based graphical interface for servers";
    license = licenses.lgpl21;
    homepage = "https://cockpit-project.org/";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
