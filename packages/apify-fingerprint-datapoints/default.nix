{
  lib,
  python3,
  pythonOlder ? python3.pkgs.pythonOlder,
  fetchPypi,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "apify-fingerprint-datapoints";
  version = "0.7.0";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    pname = "apify_fingerprint_datapoints";
    inherit version;
    hash = "sha256-eF+1x4SVY1TvlQquM0swuchBxiA82CHo4AK7/u0wk1U=";
  };

  build-system = with python3.pkgs; [ hatchling ];

  meta = {
    description = "Browser fingerprinting tools for anonymizing your scrapers";
    homepage = "https://github.com/apify/fingerprint-suite";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ encode42 ];
  };
}
