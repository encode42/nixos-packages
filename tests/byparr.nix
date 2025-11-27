{
  flake,
  pkgs,
  lib,
  ...
}:

pkgs.nixosTest {
  name = "byparr-test";

  nodes.machine =
    { config, ... }:
    {
      imports = [
        flake.nixosModules.byparr
      ];

      services.byparr = {
        enable = true;
      };
    };

  # TODO: This is a very basic test

  testScript = ''
    machine.start()
    machine.wait_for_unit("byparr.service")
    machine.succeed("systemctl is-active byparr.service")
  '';

  meta.maintainers = [ lib.maintainers.encode42 ];
}
