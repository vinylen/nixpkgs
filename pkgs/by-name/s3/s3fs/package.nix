{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  curl,
  openssl,
  libxml2,
  fuse,
}:

stdenv.mkDerivation rec {
  pname = "s3fs-fuse";
  version = "1.95";

  src = fetchFromGitHub {
    owner = "s3fs-fuse";
    repo = "s3fs-fuse";
    rev = "v${version}";
    sha256 = "sha256-wHszw3S+fuZRwTvJy+FkxQTR2BAvr8H924Wd4/C5heE=";
  };

  buildInputs = [
    curl
    openssl
    libxml2
    fuse
  ];
  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  configureFlags = [
    "--with-openssl"
  ];

  postInstall = ''
    ln -s $out/bin/s3fs $out/bin/mount.s3fs
  '';

  meta = {
    description = "Mount an S3 bucket as filesystem through FUSE";
    homepage = "https://github.com/s3fs-fuse/s3fs-fuse";
    changelog = "https://github.com/s3fs-fuse/s3fs-fuse/raw/v${version}/ChangeLog";
    maintainers = with lib.maintainers; [ ];
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.unix;
  };
}
