# https://github.com/NixOS/nixpkgs/blob/1c8ba8d3f7634acac4a2094eef7c32ad9106532c/pkgs/development/python-modules/browserforge/default.nix

{
  lib,
  python3,
  pythonOlder ? python3.pkgs.pythonOlder,
  fetchFromGitHub,
  apify-fingerprint-datapoints,
}:

python3.pkgs.buildPythonPackage {
  pname = "browserforge";
  version = "1.2.3-unstable";
  pyproject = true;

  disabled = pythonOlder "3.11";

  src = fetchFromGitHub {
    owner = "daijro";
    repo = "browserforge";
    rev = "99dd114332c17e895469107847e7193e2832504a";
    hash = "sha256-xW7+8MdxPSNLreHj+IetcjTHWGghCXJxRInRcokrBac=";
  };

  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    apify-fingerprint-datapoints
    aiofiles
    click
    httpx
    orjson
    rich
  ];

  # Module has no test
  doCheck = false;

  pythonImportsCheck = [ "browserforge" ];

  meta = {
    description = "Intelligent browser header & fingerprint generator";
    homepage = "https://github.com/daijro/browserforge";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
