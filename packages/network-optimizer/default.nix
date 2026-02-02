{
  lib,
  pkgs,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
}:

let
  webRootPath = "NetworkOptimizer.Web/wwwroot";
in
buildDotnetModule rec {
  pname = "network-optimizer";
  version = "1.1.9";

  src = fetchFromGitHub {
    owner = "Ozark-Connect";
    repo = "NetworkOptimizer";
    tag = "v${version}";
    hash = "sha256-G13GjR5R+f80sCjxKx/3uZmEbURoN69xrM5DFc/SilY=";
  };

  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;

  projectFile = "src/NetworkOptimizer.Web";

  enableParallelBuilding = false;

  nativeBuildInputs = with pkgs; [
    git
  ];

  postBuild = ''
    mkdir -p $out/share/network-optimizer/${webRootPath}

    cp -r src/${webRootPath} $out/share/network-optimizer/${webRootPath}
  '';

  meta = {
    description = "Self-hosted performance optimization and security audit tool for UniFi Networks";
    homepage = "https://github.com/Ozark-Connect/NetworkOptimizer";
    license = lib.licenses.bsl11;
    maintainers = with lib.maintainers; [ encode42 ];
    mainProgram = "NetworkOptimizer.Web";
  };
}
