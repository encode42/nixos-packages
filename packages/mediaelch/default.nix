# https://github.com/NixOS/nixpkgs/blob/0182a361324364ae3f436a63005877674cf45efb/pkgs/by-name/me/mediaelch/package.nix

{
  lib,
  stdenv,
  fetchFromGitHub,

  cmake,

  curl,
  ffmpeg,
  libmediainfo,
  libzen,
  libsForQt5,
  qt6Packages,

  qtVersion ? 6,
}:

let
  qt' = if qtVersion == 5 then libsForQt5 else qt6Packages;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "mediaelch";
  version = "2.13.0-unstable";

  src = fetchFromGitHub {
    owner = "Komet";
    repo = "MediaElch";
    rev = "d2a18102e426894f1d361e4056e940939a3a09f7";
    hash = "sha256-x55T7JSf35rkAQR5vIUUc805LLMqeQsQUrXu4/TgEeY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    qt'.qttools
    qt'.wrapQtAppsHook
  ];

  buildInputs = [
    curl
    ffmpeg
    libmediainfo
    libzen
    qt'.qtbase
    qt'.qtdeclarative
    qt'.qtmultimedia
    qt'.qtsvg
    qt'.qtwayland
    qt'.quazip
  ]
  ++ lib.optionals (qtVersion == 6) [
    qt'.qt5compat
  ];

  cmakeFlags = [
    (lib.cmakeBool "DISABLE_UPDATER" true)
    (lib.cmakeBool "ENABLE_TESTS" finalAttrs.finalPackage.doCheck or false)
    (lib.cmakeBool "MEDIAELCH_FORCE_QT${toString qtVersion}" true)
    (lib.cmakeBool "USE_EXTERN_QUAZIP" true)
  ];

  # libmediainfo.so.0 is loaded dynamically
  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${libmediainfo}/lib"
  ];

  env = {
    HOME = "/tmp"; # for the font cache
    LANG = "C.UTF-8";
    QT_QPA_PLATFORM = "offscreen"; # the tests require a UI
  };

  doCheck = true;

  checkTarget = "unit_test"; # the other tests require network connectivity

  meta = {
    homepage = "https://mediaelch.de/mediaelch/";
    description = "Media Manager for Kodi";
    mainProgram = "MediaElch";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ stunkymonkey ];
    platforms = lib.platforms.linux;
  };
})
