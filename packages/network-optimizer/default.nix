{
  lib,
  pkgs,
  buildDotnetModule,
  dotnetCorePackages,
  fetchFromGitHub,
}:

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

  dotnetBuildFlags = [
    "-p:OverridePackageVersion=${version}"
  ];

  buildPhase = ''
    runHook preBuild

    env dotnet publish $dotnetProjectFiles \
      --configuration Release \
      --self-contained \
      --output "$out/lib/${pname}" \
      --no-restore \
      ''${dotnetInstallFlags[@]}  \
      ''${dotnetFlags[@]}

    runHook postBuild
  '';

  selfContainedBuild = true;
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
