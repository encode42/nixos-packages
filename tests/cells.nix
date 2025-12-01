{
  flake,
  pkgs,
  lib,
  ...
}:

pkgs.testers.nixosTest {
  name = "cells-test";

  nodes.machine =
    { ... }:
    {
      imports = [
        flake.nixosModules.cells
      ];

      services.cells.enable = true;
    };

  # TODO: This is a very basic test

  testScript = ''
    machine.start()
    machine.wait_for_unit("cells.service")
    machine.succeed("systemctl is-active cells.service")
  '';

  meta.maintainers = [ lib.maintainers.encode42 ];
}
