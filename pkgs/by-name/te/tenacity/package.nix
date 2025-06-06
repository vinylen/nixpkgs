{
  stdenv,
  lib,
  fetchFromGitea,
  cmake,
  wxGTK32,
  gtk3,
  pkg-config,
  python3,
  gettext,
  glib,
  file,
  lame,
  libvorbis,
  libmad,
  libjack2,
  lv2,
  lilv,
  makeWrapper,
  serd,
  sord,
  sqlite,
  sratom,
  suil,
  alsa-lib,
  libsndfile,
  soxr,
  flac,
  twolame,
  expat,
  libid3tag,
  libopus,
  ffmpeg,
  soundtouch,
  pcre,
  portaudio,
  linuxHeaders,
  at-spi2-core,
  dbus,
  libepoxy,
  libXdmcp,
  libXtst,
  libpthreadstubs,
  libselinux,
  libsepol,
  libxkbcommon,
  util-linux,
}:

stdenv.mkDerivation rec {
  pname = "tenacity";
  version = "1.3.4";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "tenacityteam";
    repo = "tenacity";
    fetchSubmodules = true;
    rev = "v${version}";
    hash = "sha256-2gndOwgEJK2zDSbjcZigbhEpGv301/ygrf+EQhKp8PI=";
  };

  postPatch = ''
    mkdir -p build/src/private
    touch build/src/private/RevisionIdent.h

    substituteInPlace libraries/lib-files/FileNames.cpp \
         --replace /usr/include/linux/magic.h \
                   ${linuxHeaders}/include/linux/magic.h
  '';

  postFixup = ''
    wrapProgram "$out/bin/tenacity" \
      --suffix AUDACITY_PATH : "$out/share/tenacity" \
      --suffix AUDACITY_MODULES_PATH : "$out/lib/tenacity/modules" \
      --prefix LD_LIBRARY_PATH : "$out/lib/tenacity" \
      --prefix XDG_DATA_DIRS : "$out/share:$GSETTINGS_SCHEMAS_PATH"
  '';

  env.NIX_CFLAGS_COMPILE = "-D GIT_DESCRIBE=\"\"";

  # tenacity only looks for ffmpeg at runtime, so we need to link it in manually
  NIX_LDFLAGS = toString [
    "-lavcodec"
    "-lavdevice"
    "-lavfilter"
    "-lavformat"
    "-lavutil"
    "-lpostproc"
    "-lswresample"
    "-lswscale"
  ];

  nativeBuildInputs =
    [
      cmake
      gettext
      makeWrapper
      pkg-config
      python3
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      linuxHeaders
    ];

  buildInputs =
    [
      alsa-lib
      expat
      ffmpeg
      file
      flac
      glib
      lame
      libid3tag
      libjack2
      libmad
      libopus
      libsndfile
      libvorbis
      lilv
      lv2
      pcre
      portaudio
      serd
      sord
      soundtouch
      soxr
      sqlite
      sratom
      suil
      twolame
      wxGTK32
      gtk3
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      at-spi2-core
      dbus
      libepoxy
      libXdmcp
      libXtst
      libpthreadstubs
      libxkbcommon
      libselinux
      libsepol
      util-linux
    ];

  cmakeFlags = [
    # RPATH of binary /nix/store/.../bin/... contains a forbidden reference to /build/
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  ];

  meta = with lib; {
    description = "Sound editor with graphical UI";
    mainProgram = "tenacity";
    homepage = "https://tenacityaudio.org/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ irenes ];
    platforms = platforms.linux;
  };
}
