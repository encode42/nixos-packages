# https://github.com/NixOS/nixpkgs/blob/5ae3b07d8d6527c42f17c876e404993199144b6a/pkgs/development/python-modules/fastapi/default.nix#L140
# Won't be needed once NixOS 25.11 releases

{
  lib,
  python3,
  buildPythonPackage ? python3.pkgs.buildPythonPackage,
  fetchFromGitHub,
  pythonOlder ? python3.pkgs.pythonOlder,
}:

buildPythonPackage rec {
  pname = "fastapi";
  version = "0.116.1";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "tiangolo";
    repo = "fastapi";
    tag = version;
    hash = "sha256-sd0SnaxuuF3Zaxx7rffn4ttBpRmWQoOtXln/amx9rII=";
  };

  build-system = with python3.pkgs; [ pdm-backend ];

  pythonRelaxDeps = [
    "anyio"
    "starlette"
  ];

  dependencies = with python3.pkgs; [
    starlette
    pydantic
    typing-extensions
  ];

  optional-dependencies = {
    all =
      with python3.pkgs;
      [
        fastapi-cli
        httpx
        jinja2
        python-multipart
        itsdangerous
        pyyaml
        ujson
        orjson
        email-validator
        uvicorn
      ]
      ++ lib.optionals (lib.versionAtLeast pydantic.version "2") [
        pydantic-settings
        pydantic-extra-types
      ]
      ++ fastapi-cli.optional-dependencies.standard
      ++ uvicorn.optional-dependencies.standard;
    standard =
      with python3.pkgs;
      [
        fastapi-cli
        httpx
        jinja2
        python-multipart
        email-validator
        uvicorn
      ]
      ++ fastapi-cli.optional-dependencies.standard
      ++ uvicorn.optional-dependencies.standard;
  };

  nativeCheckInputs =
    with python3.pkgs;
    [
      anyio
      dirty-equals
      flask
      inline-snapshot
      passlib
      pyjwt
      pytestCheckHook
      pytest-asyncio
      trio
      sqlalchemy
    ]
    ++ anyio.optional-dependencies.trio
    ++ passlib.optional-dependencies.bcrypt
    ++ optional-dependencies.all;

  pytestFlags = [
    # ignoring deprecation warnings to avoid test failure from
    # tests/test_tutorial/test_testing/test_tutorial001.py
    "-Wignore::DeprecationWarning"
    "-Wignore::pytest.PytestUnraisableExceptionWarning"
  ];

  disabledTests = [
    # Coverage test
    "test_fastapi_cli"
    # Likely pydantic compat issue
    "test_exception_handler_body_access"
  ];

  disabledTestPaths = [
    # Don't test docs and examples
    "docs_src"
    "tests/test_tutorial/test_sql_databases"
  ];

  pythonImportsCheck = [ "fastapi" ];

  meta = with lib; {
    changelog = "https://github.com/fastapi/fastapi/releases/tag/${src.tag}";
    description = "Web framework for building APIs";
    homepage = "https://github.com/fastapi/fastapi";
    license = licenses.mit;
    maintainers = with maintainers; [ wd15 ];
  };
}
