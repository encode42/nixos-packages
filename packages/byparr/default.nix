{
  pkgs,
  python3,
  stdenv,
  lib,
  fetchFromGitHub,
  makeWrapper,
  camoufox,
  playwright-captcha,
}:

let
  fastapi = pkgs.callPackage ./fastapi.nix { };

  pythonDependencies = with python3.pkgs; [
    camoufox
    fastapi
    playwright
    playwright-captcha
    pydantic
    uvicorn
  ];

  pythonInterpreter = python3.withPackages (_: pythonDependencies);
in
stdenv.mkDerivation rec {
  pname = "byparr";
  version = "2.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ThePhaseless";
    repo = "Byparr";
    tag = "v${version}";
    hash = "sha256-6/yUlahcNceMHuIYsvEFLarYnkxh+IeSrvYCtKIA5r0=";
  };

  build-system = with python3.pkgs; [
    setuptools
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  dependencies = pythonDependencies;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/${pname}

    cp -r ${src}/main.py ${src}/src $out/share/${pname}/

    makeWrapper ${pythonInterpreter}/bin/python $out/bin/${pname} \
        --add-flags "$out/share/${pname}/main.py"

    runHook postInstall
  '';

  meta = {
    description = "Provides http cookies and headers for websites protected with anti-bot protections";
    homepage = "https://github.com/ThePhaseless/Byparr";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ encode42 ];
    mainProgram = "byparr";
  };
}
