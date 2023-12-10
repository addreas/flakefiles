{ stdenv
, lib
, fetchzip
, callPackage
, makeWrapper
, bison
, flex
, binutils-unwrapped
, gnumake
, pkg-config
, python
, python3
, perl
, which
, gawk
, gnused
, gnugrep
, procps
, coreutils
  # , qt48Full
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
    pkg-config
    flex
    bison
    makeWrapper
  ];

  # PDMA: json, bcc, bpf, bpftrace, snmp, mysql, postgresql, oracle, nginx, activemq, bind2, nutcracker, LIO, OpenMetrics, libvirt, infiniband, perfevent, statsd, qshape, postfix

  buildInputs = [
    python2Pkgs
    python3Pkgs
    perl
    which

    systemd
    # qt48Full # qtchooser, qmake, qmake-qt5, qmake-qt4

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
    OUT_BASE=''${out##*/}
    RANDOM_SEED=-frandom-seed=''${OUT_BASE:0:10}
    export NIX_CFLAGS_COMPILE=''\${NIX_CFLAGS_COMPILE/$RANDOM_SEED}
  '';

  out = placeholder "out";

  configureFlags = [
    "AR=${binutils-unwrapped}/bin/ar"
    "--with-make=${gnumake}/bin/make"
    "--with-tmpdir=/tmp"
    # "pcp_etc_dir=${out}/etc"
    # "pcp_run_dir=/run/pcp"
    # "pcp_tmp_dir=/tmp/pcp"
    # "pcp_tmpfile_dir=/tmp/pcp"
    # "pcp_log_dir=/var/log/pcp"
    # "pcp_sa_dir=/var/log/pcp/sa"
    # "pcp_archive_dir=/var/log/pcp/pmlogger"
    "SYSTEMD_SYSTEMUNITDIR=${out}/etc/systemd/system"
    "SYSTEMD_TMPFILESDIR=${out}/lib/tmpfiles.d"
    # "PCP_ETC_DIR=/etc"
    # "PCP_DIR=$(out)"
  ];

  postInstall = ''
    rm -r $out/var/lib/pcp/testsuite

    mv $out/etc/pcp.env .
    echo 'export PATH=$PATH:${lib.makeBinPath [gnused gawk gnugrep procps]}' | cat - pcp.env > $out/etc/pcp.env
    rm pcp.env

    sed -i s#$out/var/run#/run# $out/etc/systemd/system/pmcd.service
    
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

/*
  
  PCP_PYTHON_PROG=python3
  PCP_PERL_PROG=perl
  PCP_PLATFORM_PATHS=/usr/bin/X11:/usr/local/bin


  PCP_SYSCONF_DIR=/etc/pcp
  PCP_SYSCONFIG_DIR=/etc/sysconfig
  PCP_PMCDCONF_PATH=/etc/pcp/pmcd/pmcd.conf
  PCP_PMCDOPTIONS_PATH=/etc/pcp/pmcd/pmcd.options
  PCP_PMCDRCLOCAL_PATH=/etc/pcp/pmcd/rc.local
  PCP_PMPROXYOPTIONS_PATH=/etc/pcp/pmproxy/pmproxy.options
  PCP_PMIECONTROL_PATH=/etc/pcp/pmie/control
  PCP_PMSNAPCONTROL_PATH=/etc/pcp/pmsnap/control
  PCP_PMLOGGERCONTROL_PATH=/etc/pcp/pmlogger/control
  PCP_SECURE_DB_PATH=/etc/pcp/nssdb
  PCP_SASLCONF_DIR=/etc/sasl2

  PCP_PACCT_SYSTEM_PATH=${prefix}/var/account/pacct

*/
