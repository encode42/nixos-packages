{
  pkgs,
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "iso2god-rs";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "iliazeus";
    repo = "iso2god-rs";
    tag = "v${version}";
    hash = "sha256-Rp3ob6Ff41FiYYaDcxDYzo8/0q3Q65FWfAw7tTCWEKc=";
  };

  cargoHash = "sha256-1q2ruR2FFtIjBBR4E9Z/icbeVaec2QzWWXbHouJ2+do=";

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    openssl
  ];

  meta = {
    description = "Command-line tool to convert Xbox 360 and original Xbox ISOs into an Xbox 360 compatible Games-On-Demand file format";
    homepage = "https://github.com/iliazeus/iso2god-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ encode42 ];
    mainProgram = "iso2god";
  };
}
