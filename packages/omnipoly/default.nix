{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "omnipoly";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "kWeglinski";
    repo = "OmniPoly";
    tag = "v${version}";
    hash = "sha256-avwy+UClh+QEoo3Z0noF0W6X8YK2iNUssAUKpZ1ad0k=";
  };

  npmDepsHash = "sha256-X+5Qsnk0RIgi7pl4a0TbmVobg+pv1Ls1pwrcjn2pPPQ=";

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
