{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "2captcha-python-async";
  version = "1.5.1";

  src = fetchPypi {
    pname = "2captcha_python_async";
    inherit version;
    hash = "sha256-ydW3PdrCOovNwblrB19xZZRcDXmDb4Nw04AtnFirMjY=";
  };

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    aiofiles
    httpx
    requests
  ];

  pythonImportsCheck = [ "twocaptcha" ];

  meta = {
    description = "Easy integration with the API of 2captcha captcha solving service";
    homepage = "https://github.com/techinz/2captcha-python-async";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ encode42 ];
  };
}
