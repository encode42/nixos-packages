{
  lib,
  pkgs,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
}:

buildDotnetModule rec {
  pname = "network-optimizer";
  version = "1.0.12";

  src = fetchFromGitHub {
    owner = "Ozark-Connect";
    repo = "NetworkOptimizer";
    tag = "v${version}";
    hash = "sha256-x3zU4tl5qxe6llzQuvKBcVkh3HLUlQIyFtlK6Me8vLQ=";
  };

  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_10_0;

  enableParallelBuilding = false;

  nativeBuildInputs = with pkgs; [
    git
  ];

  meta = {
    description = "Self-hosted performance optimization and security audit tool for UniFi Networks";
    homepage = "https://github.com/Ozark-Connect/NetworkOptimizer";
    license = lib.licenses.bsl11;
    maintainers = with lib.maintainers; [ encode42 ];
    mainProgram = "NetworkOptimizer.Web";
  };
}
