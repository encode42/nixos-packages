{
  flake,
  pkgs,
  lib,
  ...
}:

pkgs.testers.nixosTest {
  name = "network-optimizer-test";

  nodes.machine =
    { config, ... }:
    {
      imports = [
        flake.nixosModules.network-optimizer
      ];

      services.network-optimizer = {
        enable = true;
      };
    };

  # TODO: This is a very basic test

  testScript = ''
    machine.start()
    machine.wait_for_unit("network-optimizer.service")
    machine.succeed("systemctl is-active network-optimizer.service")
  '';

  meta.maintainers = [ lib.maintainers.encode42 ];
}
