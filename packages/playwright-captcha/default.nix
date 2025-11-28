{
  pkgs,
  lib,
  python3,
  fetchPypi,
  captcha-python-async,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "playwright-captcha";
  version = "0.1.1";
  pyproject = true;

  src = fetchPypi {
    pname = "playwright_captcha";
    inherit version;
    hash = "sha256-6PLsfn2rhLu6UFPVaq3MEDD+dsGlMUYlzSVM0Amludc=";
  };

  build-system = with python3.pkgs; [
    setuptools
    poetry-core
  ];

  nativeBuildInputs = with pkgs; [
    dos2unix
  ];

  dependencies = with python3.pkgs; [
    playwright
    platformdirs
    captcha-python-async
  ];

  prePatch = ''
    dos2unix ./playwright_captcha/utils/camoufox_add_init_script/add_init_script.py
  '';

  patches = [
    ./use_cache_for_scripts.patch
  ];

  patchFlags = [
    "-p1"
  ];

  pythonImportsCheck = [ "playwright_captcha" ];

  meta = {
    description = "Automating captcha solving for Playwright";
    homepage = "https://github.com/techinz/playwright-captcha";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ encode42 ];
  };
}
