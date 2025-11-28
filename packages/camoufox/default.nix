{
  lib,
  python3,
  fetchPypi,
  fetchurl,
  browserforge,
  camoufox-browser,
}:

let
  geoliteDatabase = fetchurl {
    url = "https://github.com/P3TERX/GeoLite.mmdb/raw/download/GeoLite2-City.mmdb";
    hash = "sha256-JXiAzKSacZM+jB6XSQOd6hQjaBThtojjxn54BjIO4cA=";
  };
in
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
    geoip2
  ];

  patches = [
    ./use_local_browser.patch
  ];

  patchFlags = [
    "-p2"
  ];

  postInstall = ''
    ln -s ${camoufox-browser}/lib/camoufox-bin-* $out/${python3.sitePackages}/camoufox/camoufox-bin

    cp ${geoliteDatabase} $out/${python3.sitePackages}/camoufox/GeoLite2-City.mmdb
  '';

  pythonImportsCheck = [ "camoufox" ];

  meta = {
    description = "Stealthy, minimalistic, custom build of Firefox for web scraping";
    homepage = "https://github.com/daijro/camoufox";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ encode42 ];
  };
}
