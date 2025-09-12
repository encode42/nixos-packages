{
  flake,
  lib,
  pkgs,
}:

pkgs.nixosTest {
  name = "libretranslate";

  nodes.machine =
    { ... }:
    {
      imports = [
        flake.nixosModules.libretranslate
      ];

      services.libretranslate = {
        enable = true;
      };
    };

  # TODO: This is a very basic test

  testScript = ''
    start_all();

    machine.wait_for_unit("libretranslate.service")
    machine.wait_for_open_port(42010)
  '';

  meta.maintainers = [ lib.maintainers.encode42 ];
}
