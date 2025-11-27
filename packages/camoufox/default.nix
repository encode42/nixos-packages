{
  lib,
  python3,
  fetchPypi,
  browserforge,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "camoufox";
  version = "0.4.11";
  pyproject = true;

  src = fetchPypi {
    pname = "camoufox";
    inherit version;
    hash = "sha256-CiydJKxQcMEE58KxJcCjk39w76QWCE74iv6Uwypy7r4=";
  };

  build-system = with python3.pkgs; [
    setuptools
    poetry-core
  ];

  dependencies = with python3.pkgs; [
    browserforge
    click
    language-tags
    lxml
    numpy
    orjson
    platformdirs
    playwright
    pysocks
    pyyaml
    screeninfo
    tqdm
    ua-parser
    requests
  ];

  pythonImportsCheck = [ "camoufox" ];

  meta = {
    description = "Stealthy, minimalistic, custom build of Firefox for web scraping";
    homepage = "https://github.com/daijro/camoufox";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ encode42 ];
  };
}
