# https://github.com/NixOS/nixpkgs/blob/cd5fedfc384cb98d9fd3827b55f4522f49efda42/pkgs/by-name/fl/floorp-bin-unwrapped/package.nix

{
  pkgs,
  lib,
  fetchzip,
}:

let
  version = "135.0.1-beta.24";

  versionParts = lib.strings.splitString "-" version;

  packageVersion = builtins.elemAt versionParts 0;
  packageRelease = builtins.elemAt versionParts 1;
in
pkgs.stdenv.mkDerivation rec {
  pname = "camoufox-browser";
  inherit version;

  src = fetchzip {
    url = "https://github.com/daijro/camoufox/releases/download/v${version}/camoufox-${version}-lin.x86_64.zip";
    sha256 = "sha256-k5t12L5q0RG8Zun0SAjGthYQXUcf+xVHvk9Mknr97QY=";
    stripRoot = false;
  };

  nativeBuildInputs = with pkgs; [
    wrapGAppsHook3
    autoPatchelfHook
    patchelfUnstable
  ];

  buildInputs = with pkgs; [
    gtk3
    adwaita-icon-theme
    alsa-lib
    dbus-glib
    xorg.libXtst
  ];

  runtimeDependencies = with pkgs; [
    curl
    pciutils
    libva.out
  ];

  appendRunpaths = with pkgs; [
    "${pipewire}/lib"
  ];

  patchelfFlags = [ "--no-clobber-old-sections" ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$prefix/lib" "$prefix/bin"
    cp -r . "$prefix/lib/camoufox-bin-${version}"

    echo '{"version":"${packageVersion}","release":"${packageRelease}"}' > $out/lib/camoufox-bin-${version}/version.json

    ln -s "$prefix/lib/camoufox-bin-${version}/camoufox" "$out/bin/camoufox"

    runHook postInstall
  '';

  passthru = {
    binaryName = "camoufox";
    applicationName = "camoufox";
    libName = "camoufox-bin-${version}";
    ffmpegSupport = true;
    gssSupport = true;
    gtk3 = pkgs.gtk3;
  };

  meta = with pkgs.lib; {
    description = "Stealthy, minimalistic, custom build of Firefox for web scraping";
    homepage = "https://github.com/daijro/camoufox";
    license = licenses.mpl20;
    maintainers = with lib.maintainers; [ encode42 ];
  };
}
