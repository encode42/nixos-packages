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

      virtualisation.diskSize = 4096;

      services.byparr = {
        enable = true;
      };
    };

  testScript = ''
    machine.start()
    machine.wait_for_unit("byparr.service")
    machine.succeed("curl -L -X POST 'http://localhost:8191/v1' -H 'Content-Type: application/json' --data-raw '{ \"cmd\": \"request.get\", \"url\": \"http://www.google.com/\", \"maxTimeout\": 60000 }'")
  '';

  meta.maintainers = [ lib.maintainers.encode42 ];
}
