{ stdenv
, lib
, fetchzip
, callPackage
, makeWrapper
, breakpointHook
, bintools
, bison
, flex
, gnumake
, pkgconfig
, python
, python3
, perl
, which
, gawk
, gnused
, gnugrep
, procps
, coreutils
, qt48Full
, systemd
, ragel
, avahi
, libbpf
, libelf
, bpftools
, ncurses
, libuv
, libpfm
, lzma
, lzip
, readline
  # , inkscape
,
}:
let
  python2Pkgs = python.withPackages (ps: [
    ps.setuptools
    ps.six
  ]);
  python3Pkgs = python3.withPackages (ps: [
    ps.pylint
    # ps.BPF
    ps.jsonpointer
    ps.openpyxl
    ps.setuptools
    ps.requests
    ps.libvirt
    ps.six
    # ps.influxdb
  ]);
in
stdenv.mkDerivation rec {
  pname = "pcp";
  version = "5.3.7";

  src = fetchzip {
    url = "https://github.com/performancecopilot/pcp/archive/refs/tags/${version}.tar.gz";
    sha256 = "hOiIo3eE83te7UPP2l0JVN+YO76wkR8DMxrF/OdJNOU=";
  };

  nativeBuildInputs = [
    pkgconfig
    flex
    bison
    # breakpointHook
    makeWrapper
  ];

  # PDMA: json, bcc, bpf, bpftrace, snmp, mysql, postgresql, oracle, nginx, activemq, bind2, nutcracker, LIO, OpenMetrics, libvirt, infiniband, perfevent, statsd, qshape, postfix

  buildInputs = [
    python2Pkgs
    python3Pkgs
    perl
    which

    systemd
    qt48Full # qtchooser, qmake, qmake-qt5, qmake-qt4

    ragel
    avahi
    libbpf
    libelf
    bpftools
    ncurses
    libuv
    libpfm
    lzma
    lzip
    readline

    # inkscape
    # dtrace
    # gtar, hdiutil, mkinstallp, pkgmk, dlltool, rpmbuild, rpm, dpkg, makepkg
    # libzfs, curses, ncursesw, nss, nss3, nspr, nspr4
    # devmapper, infiniband, pfmlib, hdr_init, chan_init
    # selinux policy
    # altzone, cmoka
  ];

  patches = [
  ];

  postPatch = ''
    patchShebangs scripts
  '';

  preConfigure = ''
    # export CCACHE_DIR=/nix/var/cache/ccache
    # export CCACHE_UMASK=002
    # export CCACHE_NOLINK=true
    # export CCACHE_NOHASHDIR=true

    export AR=$(which ar)
    export SYSTEMD_SYSTEMUNITDIR=$out/etc/systemd/system
    export PCP_DIR=$out
  '';

  configureFlags = [
    "--with-make=${gnumake}/bin/make"
    "--with-tmpdir=/tmp$(out)"
  ];

  postInstall = ''
    rm -r $out/var/lib/pcp/testsuite
    
    mkdir -p /tmp$out

    mv $out/etc/pcp.env .
    echo 'export PATH=$PATH:${lib.makeBinPath [gnused gawk gnugrep procps]}' | cat - pcp.env > $out/etc/pcp.env
    rm pcp.env
    
    wrapProgram $out/libexec/pcp/lib/pmcd --prefix PATH : ${lib.makeBinPath [coreutils gnused]}
    wrapProgram $out/libexec/pcp/lib/pmlogger --prefix PATH : ${lib.makeBinPath [coreutils]}
  '';


  meta = with lib; {
    description = "A sysadmin login session in a web browser";
    homepage = "https://pcp.io";
    license = licenses.gpl2;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ];
  };
}
