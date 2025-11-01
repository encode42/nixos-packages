{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "omnipoly";
  version = "0.14.3";

  src = fetchFromGitHub {
    owner = "kWeglinski";
    repo = "OmniPoly";
    tag = "v${version}";
    hash = "sha256-ZDrnF17vSUr59fX4KFNcoBasroD2GGI9YmDtE8L43os=";
  };

  npmDepsHash = "sha256-PTMWlMSlNK41xk5NvkzWRNOCFukFd9GPdXOcNUB6NWg=";

  installPhase = ''
    mkdir -p $out/share/${pname}

    cp -r . $out/share/${pname}/
  '';

  meta = {
    description = "Frontend for LanguageTool and LibreTranslate";
    homepage = "https://github.com/kWeglinski/OmniPoly";
    changelog = "https://github.com/kWeglinski/OmniPoly/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ encode42 ];
  };
}
