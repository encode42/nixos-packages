{
  flake,
  pkgs,
  lib,
  ...
}:

pkgs.nixosTest {
  name = "omnipoly-test";

  nodes.machine =
    { config, ... }:
    {
      imports = [
        flake.nixosModules.omnipoly
      ];

      services.languagetool = {
        enable = true;

        port = 6000;
      };

      services.libretranslate = {
        enable = true;

        disableWebUI = true;

        port = 7000;
      };

      services.omnipoly = {
        enable = true;
      };
    };

  # TODO: This is a very basic test

  testScript = ''
    machine.start()
    machine.wait_for_unit("omnipoly.service")
    machine.succeed("systemctl is-active omnipoly.service")
  '';

  meta.maintainers = [ lib.maintainers.encode42 ];
}
